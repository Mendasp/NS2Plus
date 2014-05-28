// ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
//
// lua/Mixins/BaseModelMixin.lua
//
// Created by Max McGuire (max@unknownworlds.com)
// and Brian Cronin (brianc@unknownworlds.com)
//
// ========= For more information, visit us at http://www.unknownworlds.com =====================

//
// Extracts common model handling for both limited and full model mixins. 
//
// Limited (or client) model-mixins have a mostly cosmetic animation - their physics structure don't
// change enough to worry about running them on the server, but they are run on the client to
// render the animation properly.
//
// This means that the server don't run animation or physics updates in the normal case - they do
// run them if they are moved or rotated though (ie on coordinate changes).
//
// This mixin contains all the code and the common set of netvars. The full mixin (BaseModelMixin)
// registers the animation state as netvars, while the limited (ClientBaseModelMixin) don't.
//
// The member variable fullyUpdated is always true for the full mixin, while its true on the
// client and false on the server for the limited mixin.
//
// The member variable limitedModel is true for the limited model and false for the full model
// 
//

Script.Load("lua/PhysicsGroups.lua")
Script.Load("lua/Utility.lua")

// Cache frequently used globals for greater efficiency.
local Shared_GetModel                           = Shared.GetModel
local Shared_GetAnimationGraph                  = Shared.GetAnimationGraph
local Shared_GetTime                            = Shared.GetTime
local Shared_GetPreviousTime                    = Shared.GetPreviousTime

local Model_GetPoseParamIndex                   = Model.GetPoseParamIndex
local PoseParams_Set                            = PoseParams.Set

local AnimationGraphState_SetInputValue         = AnimationGraphState.SetInputValue
local AnimationGraphState_PrepareForGraph       = AnimationGraphState.PrepareForGraph
local AnimationGraphState_SetCurrentAnimation   = AnimationGraphState.SetCurrentAnimation
local AnimationGraphState_SetCurrentNode        = AnimationGraphState.SetCurrentNode
local AnimationGraphState_SetTime               = AnimationGraphState.SetTime
local AnimationGraphState_GetBoneCoords         = AnimationGraphState.GetBoneCoords

local Graph_GetTagName = AnimationGraph.GetTagName

local RenderModel_SetCoords
local RenderModel_SetBoneCoords
local RenderModel_SetIsVisible

if Client then
    RenderModel_SetCoords                       = RenderModel.SetCoords
    RenderModel_SetBoneCoords                   = RenderModel.SetBoneCoords
    RenderModel_SetIsVisible                    = RenderModel.SetIsVisible
end

local _dynamicPhysicsType
if Server then
    _dynamicPhysicsType = PhysicsType.DynamicServer
else
    _dynamicPhysicsType = PhysicsType.Dynamic
end

local _enableBoneUpdating = true
local _enablePoseParams   = true

BaseModelMixin = CreateMixin( BaseModelMixin )
BaseModelMixin.type = "BaseModel"

// These are functions that override existing same-named functions instead
// of the default case of combining with them.
BaseModelMixin.overrideFunctions =
{
    "GetAttachPointIndex",
    "GetAttachPointCoords",
    "GetAttachPointOrigin"
}

BaseModelMixin.optionalCallbacks =
{
    OnTag = "Will be called with the name of the tag that was passed while animating.",
    OnAdjustModelCoords = "Should adjust the passed in coordinates for cases where the model is rotated.",
    OnUpdateAnimationInput = "Update animation input for the passed in BaseModelMixin based on the state of this entity.",
    OnUpdatePoseParameters = "Update pose parameters for the passed in BaseModelMixin based on the state of this entity.",
    OnCreateCollisionModel = "Called immediately after the collison representation for the model is created.",
    GetCanSkipPhysics = "Called in OnUpdatePhysics(). If false, the OnUpdatePhysics() is skipped.",
    GetClientSideAnimationEnabled = "Return true to enable animation processing (tags) on the Client for non-local player entities."
}

// Maximum number of animations we support on in a model. This is limited for
// the sake of reducing the size of the network field.
BaseModelMixin.kMaxAnimations = 250
BaseModelMixin.kMaxGraphNodes = 511

local function DestroyRenderModel(self)

    if self._renderModel ~= nil then
    
        Client.DestroyRenderModel(self._renderModel)
        self._renderModel = nil
        
    end

end

local function DestroyPhysicsModel(self)

    if self.physicsModel ~= nil then
    
        Shared.DestroyCollisionObject(self.physicsModel)
        self.physicsModel = nil
        
    end

end

local function CaptureAnimationState(self)
    PROFILE("BaseModelMixin:CaptureAnimationState")
    local state = self.animationState

    self.animationGraphNode = state:GetCurrentNode(0)
    self.animationSequence, self.animationStart, self.animationSpeed, self.animationBlend = state:GetCurrentAnimation(0, 0)
    self.animationSequence2, self.animationStart2, self.animationSpeed2 = state:GetCurrentAnimation(0, 1)
    
    self.layer1AnimationGraphNode = state:GetCurrentNode(1)
    self.layer1AnimationSequence, self.layer1AnimationStart, self.layer1AnimationSpeed, self.layer1AnimationBlend = state:GetCurrentAnimation(1, 0)
    self.layer1AnimationSequence2, self.layer1AnimationStart2, self.layer1AnimationSpeed2 = state:GetCurrentAnimation(1, 1)

end

local function GetEntityIsRelatedTo(entity, child)

    if child == nil then
        return false
    end
    
    if entity == child then
        return true
    end
    
    return GetEntityIsRelatedTo(entity, child:GetParent())
    
end

local function UpdateAnimationInput(self, state, graph)

    if self.OnUpdateAnimationInput then
    
        PROFILE("BaseModelMixin:OnUpdateAnimationInput")
        self:OnUpdateAnimationInput(self)
        
        //pairs is not yet traceable
        TraceStopPoint()
        
        for name, value in pairs(self.animationInputValues) do
            AnimationGraphState_SetInputValue(state, graph, name, value)    
        end
        
    end
    
end

/**
 * UpdateAnimationState should be called at the end of OnProcessMove on the client and server.
 * If OnProcessMove is not called then OnUpdate on the client and server should do this.
 */
local function UpdateAnimationState(self, allowedOnClient, transition)

    // On the server, we always updates the animation graphs to trigger OnTag events.
    // On the client, fullyUpdated models can skip its animation state because its controlled from the server, except for those that are
    // handled for the local player. So only limited models or entities related to the local player must be updated.
    
    // GetClientSideAnimationEnabled() is allows animation processing on the Client for non-local player related entities.
    // This is useful if animation tags need to be processed on the Client for example.
    // Ideally this would not be necessary. It would be best if animation tags were processed in all cases but the other
    // animation work would only happen under the other conditions listed here.
    // Predict only runs animation updates for the local players OnProcessMove so it will always trigger
    local allowed = Predict ~= nil
        or Server ~= nil
        or
        (
            Client and
            (
                self.limitedModel
                or GetEntityIsRelatedTo(Client.GetLocalPlayer(), self)
                or (self.GetClientSideAnimationEnabled and self:GetClientSideAnimationEnabled())
            )
        )
    
    local model = Shared_GetModel(self.modelIndex)
    local graph = Shared_GetAnimationGraph(self.animationGraphIndex)
    
    if allowed and model ~= nil and graph ~= nil then

        PROFILE("BaseModelMixin:UpdateAnimationState")
    
        local prevTime = Shared_GetPreviousTime()
        local time = Shared_GetTime()
        
        local state = self.animationState
        
        UpdateAnimationInput(self, state, graph)
        
        table.clear(self.passedTags)
        state:Update(graph, model, self.poseParams, prevTime, time, self.passedTags)
        
        if transition then
        
            local self_OnTag = self.OnTag
            if self_OnTag then
                for i = 1,#self.passedTags do
                    local tagIndex = self.passedTags[i]
                    self_OnTag(self, Graph_GetTagName(graph, model, tagIndex))
                end
            end
            
            // Tags may have caused state to change that influences the animation input.
            if table.count(self.passedTags) > 0 then
                UpdateAnimationInput(self, state, graph)
            end
            
            if allowedOnClient or Server then
            
                // Transition is called after tag callbacks because the tags can cause state
                // to change within the animation graph.
                table.clear(self.passedTags)
                state:Transition(graph, model, self.passedTags)
                
                if self_OnTag then
      
                    for i = 1,#self.passedTags do
                        local tagIndex = self.passedTags[i]
                        self_OnTag(self, Graph_GetTagName(graph, model, tagIndex))
                    end
                end
                
            end
        
        end
        
        CaptureAnimationState(self)
        
    end
    
end

local function SynchronizeAnimation(self, syncNodesOnServer)

    PROFILE("BaseModelMixin:SynchronizeAnimation")

    // Sync the graph with the network state.
    local graph = Shared_GetAnimationGraph(self.animationGraphIndex)

    if graph ~= nil then
        
        local state = self.animationState
        AnimationGraphState_PrepareForGraph(state, graph)
            
        AnimationGraphState_SetCurrentAnimation(state, 0, 0, self.animationSequence, self.animationStart, self.animationSpeed, self.animationBlend)
        AnimationGraphState_SetCurrentAnimation(state, 0, 1, self.animationSequence2, self.animationStart2, self.animationSpeed2, 1.0)

        // Since the animation graph index isn't lag compensated, we don't want
        // to revert the nodes during lag compensation on the server. If we did
        // the nodes and the animation graph wouldn't match up.
        if Client or Predict or syncNodesOnServer then
	        AnimationGraphState_SetCurrentNode(state, 0, self.animationGraphNode)
	        AnimationGraphState_SetCurrentNode(state, 1, self.layer1AnimationGraphNode)
        end
        
        AnimationGraphState_SetCurrentAnimation(state, 1, 0, self.layer1AnimationSequence, self.layer1AnimationStart, self.layer1AnimationSpeed, self.layer1AnimationBlend)
        AnimationGraphState_SetCurrentAnimation(state, 1, 1, self.layer1AnimationSequence2, self.layer1AnimationStart2, self.layer1AnimationSpeed2, 1.0)

        AnimationGraphState_SetTime( state, Shared_GetTime() )
        
    end        

end

local function UpdatePoseParameters(self, forceUpdate)

    if self.OnUpdatePoseParameters and not Shared.GetIsRunningPrediction() and (self.fullyUpdated or forceUpdate) then
    
        PROFILE("BaseModelMixin:OnUpdatePoseParameters")
        if _enablePoseParams then
            self:OnUpdatePoseParameters(self)
        else
            self.poseParams = PoseParams()
        end
        
    end

end

function BaseModelMixin:CopyAnimationState(other)
    for k, v in pairs(ModelMixin.networkVars) do
        self[k] = other[k]
    end 
    UpdatePoseParameters(self, true)
    SynchronizeAnimation(self, true)
end

local function UpdatePhysicsModelCoords(self, forceUpdate)

    PROFILE("BaseModelMixin:UpdatePhysicsModelCoords")

    if (self.fullyUpdated or forceUpdate) and self.physicsModel ~= nil then
    
        local update = self.physicsType == PhysicsType.Kinematic or self.physicsType == PhysicsType.None
        
        if Client and self.physicsType == PhysicsType.DynamicServer then
            update = true
        end

        if update then
            // Update the physics model based on the current bone animation.
            self.physicsModel:SetBoneCoords(self._modelCoords, self.boneCoords)
        end
        
    end

end

local function UpdateBoneCoords(self, forceUpdate)

    PROFILE("BaseModelMixin:UpdateBoneCoords")
    
    if not (self.fullyUpdated or forceUpdate) then
        return
    end
    
    UpdatePoseParameters(self, forceUpdate)
    
    local model = Shared_GetModel(self.modelIndex)
    local physicsType = self.physicsType
    
    if model ~= nil and physicsType ~= _dynamicPhysicsType then
        AnimationGraphState_GetBoneCoords(self.animationState, model, self.poseParams, self.boneCoords)
    end
    
    local modelCoords = nil
    local physicsModel = self.physicsModel
    if physicsModel and physicsType == PhysicsType.Dynamic then
        modelCoords = physicsModel:GetCoords()
    else
        modelCoords = self:GetCoords()
    end
    
    local OnAdjustModelCoords = self.OnAdjustModelCoords
    if OnAdjustModelCoords then
        self._modelCoords = OnAdjustModelCoords(self, modelCoords)
    else
        self._modelCoords = modelCoords
    end
    
    UpdatePhysicsModelCoords(self, forceUpdate)
    
end

local function ResetAnimationState(self)

    local model = Shared_GetModel(self.modelIndex)
    local graph = Shared_GetAnimationGraph(self.animationGraphIndex)
    
    if model ~= nil and graph ~= nil then
    
        // it seems AnimationGraphState:Reset doesn't work properly. Randomly the animation input is discarded when changing model / graph.
        // To make sure the graph is initialized correctly here we just throw away the old object, create a new one and update the anim input:
        self.animationState = AnimationGraphState()
        UpdateAnimationState(self, true, true)
        
        // old code:
        //self.animationState:Reset(graph, model, Shared_GetTime())
        //CaptureAnimationState(self)
        
    end

end

local function UpdateOpacity(self, debug)

    local opacity = 1
    
    if self._renderModel then
    
        if debug then
            Print("----- %s:SetOpacity ------ ", self:GetClassName())
        end
        
        self:InstanceMaterials()
        //pairs is not yet traceable
        TraceStopPoint()
        
        for identifier, value in pairs(self.opacityValues) do
        
            opacity = opacity * value
            if debug then
                Print("%s: %s", identifier, ToString(value))
            end
            
        end
        
        self._renderModel:SetMaterialParameter("hiddenAmount", Clamp(1 - opacity, 0, 1))
        
        if debug then
            Print("----- ---------- ------ ")
        end
        
    end
    
end

/** 
 * Creates the rendering representation of the model if it doesn't match
 * the currently set model index and update's it state to match the entity.
 * Pass in Coords to indicate where the model should be rendered at.
 */
local function UpdateRenderModel(self)

    if self.oldModelIndex ~= self.modelIndex then
    
        local renderModel = self._renderModel
        
        if self.modelIndex ~= 0 then
        
            self._renderModel = Client.CreateRenderModel(self:GetMixinConstants().kRenderZone or RenderScene.Zone_Default)
            self._renderModel:SetModel(self.modelIndex)
            
            if self.instanceMaterials then
                self._renderModel:InstanceMaterials()
            end
            
            UpdateOpacity(self)
            
        else
            self._renderModel = nil
        end
        
        if renderModel ~= nil then
        
            if self._renderModel then
            
                // Copy the material layers (if any)
                for i = 1, renderModel:GetNumLayers() do
                
                    local material = renderModel:GetLayer(i - 1)
                    self._renderModel:AddMaterial(material)
                    
                end
                
            end
            
            Client.DestroyRenderModel(renderModel)
            
        end
        
        // Save off the model index so we can detect when it changes.
        self.oldModelIndex = self.modelIndex
        
        if self.OnModelChanged then
            self:OnModelChanged(self.modelIndex ~= 0)
        end
        
        self:UpdatePhysicsModel()
        UpdateBoneCoords(self, true)  
    end

    // if we are teleporting right now, we need to block the render model from updating
    local getForbidModelCoordsUpdate = self.GetForbidModelCoordsUpdate
    local allowUpdates = not (getForbidModelCoordsUpdate and getForbidModelCoordsUpdate(self))
    
    local renderModel = self._renderModel
    if renderModel ~= nil and allowUpdates then
    
        // Update the render model's coordinate frame to match the entity.
        RenderModel_SetCoords(renderModel, self._modelCoords)
        
        if _enableBoneUpdating then
            RenderModel_SetBoneCoords(renderModel, self.boneCoords)
        else
            // Just use the reference pose for debugging.
            local model = Shared_GetModel(self.modelIndex)
            local poses = PosesArray()
            model:GetReferencePose(poses)
            local boneCoords = CoordsArray()
            model:GetBoneCoords(poses, boneCoords)
            RenderModel_SetBoneCoords(renderModel, boneCoords)
        end
        
        // Show or hide the model depending on whether or not the
        // entity is visible. This allows the owner to show or hide it as needed.
        RenderModel_SetIsVisible(renderModel, self:GetIsVisible())
        
    end
    
end

local function CalculateBoneVelocities(self, velocity)

    local model = Shared_GetModel(self.modelIndex)
    local graph = Shared_GetAnimationGraph(self.animationGraphIndex)
    local velocities = nil
    
    if model ~= nil and graph ~= nil then
    
        local deltaTime = 1 / 10
        local time = Shared_GetTime()
        local prevTime = time - deltaTime
        
        local state = self.animationState
        local poseParams = self.poseParams
        local previousBoneCoords = CoordsArray()
        
        state:Update(graph, model, poseParams, time, prevTime, { })
        state:GetBoneCoords(model, poseParams, previousBoneCoords)
        state:Update(graph, model, poseParams, prevTime, time, { })
        
        // Make sure the previous bone coords are correct. In the case where an entity
        // is created initially as a dynamic object, the bone coords will not have been
        // updated.
        if self.boneCoords:GetSize() ~= previousBoneCoords:GetSize() then
            self.animationState:GetBoneCoords(model, self.poseParams, self.boneCoords)
        end
        
        velocities = VelocityArray()
        Shared.CalculateBoneVelocities(self:GetCoords(), velocity, previousBoneCoords, self.boneCoords, deltaTime, velocities)
        
    end
    
    return velocities
    
end

local kDefaultRootVelocity = Vector(0, 0, 0)
local function ApplyBoneVelocities(self)

    local rootVelocity = kDefaultRootVelocity
    if self.GetVelocityFromPolar then
        rootVelocity = self:GetVelocityFromPolar()
    end
    
    local velocities = CalculateBoneVelocities(self, rootVelocity)
    if self.physicsModel ~= nil and velocities ~= nil then
        self.physicsModel:SetBoneVelocities(velocities)
    end
    
end

local function UpdatePhysicsModelSimulation(self)

    // DL: Avoid expensive switching to/from physics while running prediction.
    // This also solves the problem of physical objects losing their initial velocities / forces.
    if Shared.GetIsRunningPrediction() then
        return
    end
    
    if self.physicsModel ~= nil then
    
        local newPhysicsType = CollisionObject.None
        
        if self.physicsType == PhysicsType.DynamicServer then
        
            if Server then
                newPhysicsType = CollisionObject.Dynamic
            else
                newPhysicsType = CollisionObject.Kinematic
            end
            
        elseif self.physicsType == PhysicsType.Dynamic and Client then
            newPhysicsType = CollisionObject.Dynamic
        elseif self.physicsType == PhysicsType.Kinematic then
            newPhysicsType = CollisionObject.Kinematic
        end
        
        if newPhysicsType ~= self.physicsModel:GetPhysicsType() then
        
            self.physicsModel:SetPhysicsType(newPhysicsType)
            if newPhysicsType == CollisionObject.Dynamic then
                ApplyBoneVelocities(self)
            end
            
        end
        
        self.physicsModel:SetPhysicsCollisionRep(self.collisionRep)
        
    end
    
end

BaseModelMixin.networkVars =
{
    modelIndex = "resource",
    animationGraphIndex = "resource",
    
    // Physics.
    physicsType = "enum PhysicsType",
    collisionRep = "integer (0 to 31)",
    physicsGroup = "integer (0 to 31)",
    physicsGroupFilterMask = "integer"
}

function BaseModelMixin:__initmixin()

    // Defaults to full model.
    self.limitedModel = false
    self.fullyUpdated = true
    
    self.opacityValues = { }
    
    self.modelIndex = 0
    self.animationGraphIndex = 0
    
    self.boneCoords = CoordsArray()
    self.poseParams = PoseParams()
    self.animationState = AnimationGraphState()
    
    self.animationGraphNode = -1
    self.animationSequence = -1
    self.animationSequence2 = -1
    
    self.layer1AnimationGraphNode = -1
    self.layer1AnimationSequence = -1
    self.layer1AnimationSequence2 = -1
    
    self.animationStart = 0
    self.animationSpeed = 1
    self.animationBlend = 0
    // Blended animation.
    
    self.animationStart2 = 0
    self.animationSpeed2 = 0
    
    self.layer1AnimationStart = 0
    self.layer1AnimationBlend = 0
    self.layer1AnimationSpeed = 1
    // Blended animation.
    self.layer1AnimationSequence2 = 0
    self.layer1AnimationStart2 = 0
    self.layer1AnimationSpeed2 = 0
    
    assert(self.physicsModel == nil)
    self.physicsModelIndex = 0
    self.physicsType = PhysicsType.None
    self.collisionRep = CollisionRep.Default
    self.physicsGroup = PhysicsGroup.DefaultGroup
    self.physicsGroupFilterMask = PhysicsMask.None
    
    self:SetPhysicsGroup(self.physicsGroup)
    self:SetPhysicsGroupFilterMask(self.physicsGroupFilterMask)
    
    self.passedTags = { }
    
    self.animationInputValues = { }
    
end

function BaseModelMixin:OnInitialized()
    self:MarkPhysicsDirty()
end

function BaseModelMixin:MarkPhysicsDirty()

    local desiredModelIndex = self.modelIndex
    if self.boundingBoxModelIndex ~= desiredModelIndex then
    
        self.boundingBoxModelIndex = desiredModelIndex
        self:SetPhysicsBoundingBox(desiredModelIndex)
        
    else
        self:UpdatePhysicsBoundingBox()
    end
    
end

function BaseModelMixin:OnDestroy()

    DestroyRenderModel(self)
    DestroyPhysicsModel(self)
    
end

function BaseModelMixin:OnUpdate(deltaTime)

    PROFILE("BaseModelMixin:OnUpdate")
    
    if Server and self.fullyUpdated then
        SynchronizeAnimation(self)
        self:MarkPhysicsDirty()
        
        // force update here
        if self:GetHasClientModel() then
            self:OnUpdatePhysics()
        end
        
    end

    UpdateAnimationState(self, self.fullyUpdated, true)

end

function BaseModelMixin:OnProcessIntermediate(input)

    PROFILE("BaseModelMixin:OnProcessIntermediate")

    UpdateAnimationState(self, true, false)
    self:MarkPhysicsDirty()
    
end

function BaseModelMixin:ProcessMoveOnModel()

    PROFILE("BaseModelMixin:ProcessMoveOnModel")
    
    UpdateAnimationState(self, true, true)
    self:MarkPhysicsDirty()
    
end

/**
 * Specify nil for the fileName for no animation graph.
 * The graph should only be set on the Server through this function
 * as it will be synchronized to the Client. We don't want to set it on
 * the Client and then shortly after synchronize it from the Server. This can
 * result in the model displaying in the default, non-animated pose shortly
 * before synchronization happens.
 */
local function SetAnimationGraph(self, fileName)

    local graphChanged = false
    
    if fileName == nil then
        self.animationGraphIndex = 0
    else
    
        local newGraphIndex = Shared.GetAnimationGraphIndex(fileName)
        if newGraphIndex == 0 then
            error("Animation graph " .. fileName .. " does not exist")
        end
        
        if self.animationGraphIndex ~= newGraphIndex then
        
            graphChanged = true
            self.animationGraphIndex = newGraphIndex
            
        end
        
    end
    
    return graphChanged
    
end

/**
 * Assigns the model. modelName is a string specifying the file name of the model,
 * which should have been precached by calling Shared.PrecacheModel during load time.
 * Pass in a graph name as the second parameter or nil to clear the graph.
 * Returns true if the model or graph was changed.
 * The model should only be set on the Server through this function
 * as it will be synchronized to the Client. We don't want to set it on
 * the Client and then shortly after synchronize it from the Server. This can
 * result in the model displaying in the default, non-animated pose shortly
 * before synchronization happens.
 */
function BaseModelMixin:SetModel(modelName, graphName)
    
    local prevModelIndex = self.modelIndex

    if modelName == nil then
        self.modelIndex = 0
    else
        self.modelIndex = Shared.GetModelIndex(modelName)
    end
    
    if self.modelIndex == 0 and modelName ~= nil and modelName ~= "" then
        Shared.Message("Model '" .. modelName .. "' wasn't precached")
    end
    
    local modelChanged = self.modelIndex ~= prevModelIndex
    
    if modelChanged then
    
        // Clear out the graph when the model changes.
        // A new graph must be set after this point.
        self.animationGraphIndex = 0
        
    end
   
    self:UpdatePhysicsModel()
    UpdateBoneCoords(self, true)
    
    local graphChanged = SetAnimationGraph(self, graphName)
    
    if modelChanged or graphChanged then
        ResetAnimationState(self)
    end
    
    return modelChanged or graphChanged

end

/**
 * Forces the graph to reset. The current node will be whatever node was
 * defined as the starting node in the graph editor.
 */
function BaseModelMixin:ResetAnimationGraphState()
    ResetAnimationState(self)
end

function BaseModelMixin:GetRenderModel()

    -- Sometimes GetRenderModel() is called inside of a function like
    -- OnProcessMove() which is called BEFORE OnUpdateRender() is called
    -- which is what normally creates the renderModel. This check covers
    -- that case.
    if not self._renderModel then
        UpdateRenderModel(self)
    end
    
    return self._renderModel
    
end
function BaseModelMixin:GetCollisionModel()
    return self.physicsModel
end

function BaseModelMixin:GetHasModel()
    return Shared_GetModel(self.modelIndex) ~= nil
end

function BaseModelMixin:GetModelName()

    local model = Shared_GetModel(self.modelIndex)
    if model then
        return model:GetFileName()
    end
    
    return ""
    
end

function BaseModelMixin:GetGraphName()

    local graph = Shared_GetAnimationGraph(self.animationGraphIndex)
    if graph then
        return graph:GetFileName()
    end
    
    return ""
    
end

/**
 * Returns the value of the pose parameter name passed in.
 */
function BaseModelMixin:GetPoseParam(name)

    local model = Shared_GetModel(self.modelIndex)
    local paramIndex = -1
    if model ~= nil then
        paramIndex = Model_GetPoseParamIndex(model, name)
    end
    // Note, API will properly handle -1 paramIndex value
    return self.poseParams:Get(paramIndex)
    
end

/**
 * Sets a parameter used to compute the final pose of an animation. These are
 * named in the .model file and are usually things like the amount the
 * entity is moving, the pitch of the view, etc. This only applies to the currently
 * set model, so if the model is changed, the values will need to be reset.
 * Returns true if the pose parameter was found and set.
 */
function BaseModelMixin:SetPoseParam(name, value)
    
    local model = Shared_GetModel(self.modelIndex)
    if model ~= nil then
        local paramIndex = Model_GetPoseParamIndex(model, name)
        // Note, API will properly handle -1 paramIndex value
        PoseParams_Set(self.poseParams, paramIndex, value)
    end
    
end

function BaseModelMixin:GetAttachPointIndex(attachPointName)
    PROFILE("BaseModelMixin:GetAttachPointIndex")
    local model = Shared_GetModel(self.modelIndex)
    
    if model ~= nil then
        return model:GetAttachPointIndex(attachPointName)
    end
	
    return -1

end

/**
 * Pass attach point index or attach point name on the model and the world space
 * Coords of the attach point will be returned.
 */
function BaseModelMixin:GetAttachPointCoords(attachPoint)

    PROFILE("BaseModelMixin:GetAttachPointCoords")
    
    local attachPointIndex = attachPoint
    if type(attachPointIndex) == "string" then
        attachPointIndex = self:GetAttachPointIndex(attachPoint)
    end
    
    local model = Shared_GetModel(self.modelIndex)
    
    if attachPointIndex > -1 and model ~= nil then
    
        local attachPointExists = model:GetAttachPointExists(attachPointIndex)
        ASSERT(attachPointExists, self:GetClassName() .. ":GetAttachPointCoords(" .. attachPointIndex .. "): Attach point doesn't exist. Named: " .. ToString(attachPoint) .. " Model Name: " .. model:GetFileName() .. " Point Name: " .. ToString(attachPoint))
        
        local coords = self._modelCoords
        if attachPointExists and coords ~= nil then
            return self._modelCoords * model:GetAttachPointCoords(attachPointIndex, self.boneCoords)
        end
        
    end
    
    return Coords.GetIdentity()
    
end

function BaseModelMixin:GetAttachPointOrigin(attachPointName)
    PROFILE("BaseModelMixin:GetAttachPointOrigin")
    local attachPointIndex = self:GetAttachPointIndex(attachPointName)
    local origin  = nil
    local success = false
    
    if attachPointIndex ~= -1 then
    
        origin = self:GetAttachPointCoords(attachPointIndex).origin
        success = true
        
    else
    
        // used for models where the source files are not available for hard coding attach points (for example Mines.lua)
        if self.GetAttachPointOriginHardcoded then
        
            origin = self:GetAttachPointOriginHardcoded(attachPointName)
            success = true
            
        else
        
            origin = self:GetOrigin()
            
        end
        
    end
    
    return Vector(origin), success
    
end

/**
 * Returns the mesh's center, in world coordinates. Needed because some objects
 * have their origin at the ground and others don't.
 */
function BaseModelMixin:GetModelOrigin()

    local model = Shared_GetModel(self.modelIndex)
    
    if model ~= nil then
    
        local c = self._modelCoords
        return c.origin + c:TransformVector(model:GetOrigin())
        
    else
        return self:GetOrigin()
    end
    
end

function BaseModelMixin:GetModelExtents()

    local model = Shared_GetModel(self.modelIndex)
    
    if model ~= nil then
    
        local min, max = model:GetExtents(self.boneCoords)
        return min, max
        
    end
    
    return nil
    
end

/**
 * Returns the number of cameras in the model.
 */
function BaseModelMixin:GetNumModelCameras()

    local model = Shared_GetModel(self.modelIndex)
    if model then
        return model:GetNumCameras()
    end
    
    return 0
    
end

/**
 * Returns the camera in this model at the passed in index or
 * nil if there is no camera at the passed in index.
 */
function BaseModelMixin:GetModelCamera(index)

    local model = Shared_GetModel(self.modelIndex)
    if model then
    
        local numCameras = model:GetNumCameras()
        if index >= 0 and index < numCameras then
            return model:GetCamera(index, self.boneCoords)
        end
        
    end
    
    return nil
    
end

function BaseModelMixin:SetAnimationInput(name, value)

    assert(name ~= nil)
    assert(value ~= nil)
    
    self.animationInputValues[name] = value
    
end

function BaseModelMixin:OnUpdateRender()

    PROFILE("BaseModelMixin:OnUpdateRender")
    
    UpdateRenderModel(self)
    
end

local function UpdatePhysicsBoneCoords(self)

    if self.physicsType == _dynamicPhysicsType and self.physicsModel then
    
        // Only update the origin and angles on the server. On the client we
        // just pass these directly to the rendering system, so that the origin
        // and angles still match what the server has.
        if Server then
            
            local coords = self.physicsModel:GetCoords()
        
            local angles = Angles()
            angles:BuildFromCoords(coords)
            
            self:SetAngles(angles)
            self:SetOrigin(coords.origin)
            
        end
        
        // Update the bones based on the simulation of the physics model.
        if self.physicsModel then
            self.physicsModel:GetBoneCoords(self.boneCoords)
        end
        
    end
    
end

function BaseModelMixin:OnUpdatePhysics()

    if self.GetCanSkipPhysics and self:GetCanSkipPhysics() then
    
        PROFILE("BaseModelMixin:OnUpdatePhysicsSkip")
        return
        
    end
    
    if self.fullyUpdated then
    
        PROFILE("BaseModelMixin:OnUpdatePhysics")
        
        SynchronizeAnimation(self)
        
        UpdateBoneCoords(self)
        
        self:UpdatePhysicsModel()
        UpdatePhysicsBoneCoords(self)
        
    end
    
end


function BaseModelMixin:UpdatePhysicsModel()

    PROFILE("BaseModelMixin:UpdatePhysicsModel")
    
    // Create a physics model if necessary.
    if (self.physicsModelIndex ~= self.modelIndex) and self:GetPhysicsModelAllowed() then
    
        DestroyPhysicsModel(self)
        
        self.physicsModelIndex = self.modelIndex
        if self.physicsModelIndex ~= 0 then
            self.physicsModel = Shared.CreatePhysicsModel(self.physicsModelIndex, true, self:GetCoords(), self)
        end
        
        if self.physicsModel ~= nil then
            self.physicsModel:SetEntity(self)
            if self.OnCreateCollisionModel then
                self:OnCreateCollisionModel()
            end
        end
        
    end
    
    // Update the state of the physics model.
    if self.physicsModel ~= nil then
    
        self.physicsModel:SetGroup(self.physicsGroup)
        self.physicsModel:SetGroupFilterMask(self.physicsGroupFilterMask)
        self.physicsModel:SetCollisionEnabled(self:GetIsVisible())
        UpdatePhysicsModelSimulation(self)
        
    end
    
end

/**
 * By default every entity is allowed to have a physics model.
 * Classes can override this behavior through this method.
 */
function BaseModelMixin:GetPhysicsModelAllowed()

    if self.GetPhysicsModelAllowedOverride then
        return self:GetPhysicsModelAllowedOverride()
    end
    
    return true
    
end

/**
 * Sets whether or not the entity is physically simulated. A physically
 * simulated entity will have its bones updated based on the simulation of
 * its physics representation (ragdoll). If an entity is not physically
 * simulated, the physics respresentation will be updated based on the
 * animation that is playing on the model.
 */
function BaseModelMixin:SetPhysicsType(physicsType)

    // Update the bone coords before changing physics type so that the physics
    // model coords are updated.
    if self.physicsModel ~= nil then
        UpdateBoneCoords(self, true)
    end
    
    self.physicsType = physicsType
    
    if self.physicsModel ~= nil then
        UpdatePhysicsModelSimulation(self)
    end
    
end

function BaseModelMixin:SetPhysicsCollisionRep(collisionRep)

    self.collisionRep = collisionRep
    
    if self.physicsModel ~= nil then
        UpdatePhysicsModelSimulation(self)
    end
    
end

function BaseModelMixin:GetPhysicsType()
    return self.physicsType
end

function BaseModelMixin:GetPhysicsGroup()
    return self.physicsGroup
end

function BaseModelMixin:GetPhysicsGroupFilterMask()
    return self.physicsGroupFilterMask
end

function BaseModelMixin:SetPhysicsGroup(physicsGroup)

    self.physicsGroup = physicsGroup
    
    if self.physicsModel ~= nil then
        self.physicsModel:SetGroup(physicsGroup)
    end
    
end

function BaseModelMixin:SetPhysicsGroupFilterMask(physicsGroupFilterMask)

    self.physicsGroupFilterMask = physicsGroupFilterMask
    
    if self.physicsModel ~= nil then
        self.physicsModel:SetGroupFilterMask(physicsGroupFilterMask)
    end
    
end

function BaseModelMixin:GetPhysicsType()
    return self.physicsType
end

function BaseModelMixin:GetPhysicsModel()
    return self.physicsModel
end

function BaseModelMixin:AddImpulse(position, direction)

    if self.physicsModel then
        self.physicsModel:AddImpulse(position, direction)
    else
        Print("%s:AddImpulse(%s, %s): No physics model.", self:GetClassName(), ToString(position), ToString(direction))
    end
    
end

function BaseModelMixin:LogAnimationState()

    local graph = Shared_GetAnimationGraph(self.animationGraphIndex)
    local model = Shared_GetModel(self.modelIndex)
    if graph and model then
    
        Shared.Message(string.format("model = %s, graph = %s", self:GetModelName(), graph:GetFileName()))
        self.animationState:LogState(graph, model)
        
    end
    
end

function BaseModelMixin:SetOpacity(value, identifier, debug)

    assert(value)
    assert(identifier)
    
    self.opacityValues[identifier] = value
    UpdateOpacity(self, debug)
    
end

function BaseModelMixin:InstanceMaterials()

    if not self.instanceMaterials and self._renderModel then
        self._renderModel:InstanceMaterials()
    end
    
    self.instanceMaterials = true
    
end

function BaseModelMixin:GetHasClientModel()
    return self.limitedModel
end

/** Returns true if the model was rendered last frame. */
function BaseModelMixin:GetWasRenderedLastFrame()

    if self._renderModel == nil then
        return false
    end
    return self._renderModel:GetNumFramesInvisible() == 0
    
end

local function SetBoneUpdatingEnabled(enable)

    _enableBoneUpdating = enable == "true"
    if _enableBoneUpdating then
        Shared.Message("Bone updating enabled")
    else
        Shared.Message("Bone updating disabled")
    end
    
end

local function SetPoseParamsEnabled(enable)

    _enablePoseParams = enable == "true"
    if _enablePoseParams then
        Shared.Message("Pose params enabled")
    else
        Shared.Message("Pose params disabled")
    end
    
end

local OnCommandAnimationEnable = nil
local OnCommandPoseParamsEnable = nil

if Server then

    OnCommandAnimationEnable = function(client, enable)
        if not client or Shared.GetCheatsEnabled() then
            SetBoneUpdatingEnabled(enable)
        end
    end

    OnCommandPoseParamsEnable = function(client, enable)
        if not client or Shared.GetCheatsEnabled() then
            SetPoseParamsEnabled(enable)
        end
    end

    
else

    OnCommandAnimationEnable = function(enable)
        if Shared.GetCheatsEnabled() then
            SetBoneUpdatingEnabled(enable)
        end
    end
    
    OnCommandPoseParamsEnable = function(enable)
        if Shared.GetCheatsEnabled() then
            SetPoseParamsEnabled(enable)
        end
    end    
end

Event.Hook("Console_r_animation", OnCommandAnimationEnable)
Event.Hook("Console_r_poseparams", OnCommandPoseParamsEnable)
