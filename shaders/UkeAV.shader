source      = "shaders/UkeAV.hlsl"
techniques  =
    [
        {
            name                                = "SFXDarkVision"
            vertex_shader                       = "SFXBasicVS"
            pixel_shader                        = "SFXDarkVisionPS"
            depth_test                          = always
            depth_write                         = false
            cull_mode                           = none
        }
    ]
