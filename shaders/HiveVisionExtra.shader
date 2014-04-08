source      = "shaders/HiveVisionExtra.hlsl"
techniques  =
    [
        {
            name                                = "Mask"
            vertex_shader                       = "SFXBasicVS"
            pixel_shader                        = "MaskPS"
            depth_test                          = always
            depth_write                         = false
            cull_mode                           = none
        }
        {
            name                                = "DownSample"
            vertex_shader                       = "SFXBasicVS"
            pixel_shader                        = "DownSamplePS"
            depth_test                          = always
            depth_write                         = false
            cull_mode                           = none
        }
        {
            name                                = "Composite"
            vertex_shader                       = "SFXBasicVS"
            pixel_shader                        = "CompositePS"
            depth_test                          = always
            depth_write                         = false
            cull_mode                           = none
        }
        {
            name                                = "FinalComposite"
            vertex_shader                       = "SFXBasicVS"
            pixel_shader                        = "FinalCompositePS"
            depth_test                          = always
            depth_write                         = false
            cull_mode                           = none
        }
        
    ]