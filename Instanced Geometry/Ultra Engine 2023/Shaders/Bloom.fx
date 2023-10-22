{
    "posteffect":
    {
        "textures":
        [
            {
                "size": [0.5, 0.5],
                "format": 97,
                "miplevels": 3
            },
            {
                "size": [0.5, 0.5],
                "format": 97,
                "miplevels": 3
            }
        ],
        "subpasses":
        [
            {
                "colorattachments": [0],
                "samplers": [ "PREVPASS" ],
                "mipLevel": 0,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomBlurX.frag.spv"
                    }
                }
            },
            {
                "colorattachments": [1],
                "samplers": [0],
                "mipLevel": 0,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomBlurY.frag.spv"
                    }
                }
            },   
            
            {
                "colorattachments": [0],
                "samplers": [1],
                "mipLevel": 1,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomBlurX.frag.spv"
                    }
                }
            },
            {
                "colorattachments": [1],
                "samplers": [0],
                "mipLevel": 1,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomBlurY.frag.spv"
                    }
                }
            },             

            {
                "colorAttachments": [0],
                "samplers": [1],
                "mipLevel": 2,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomBlurX.frag.spv"
                    }
                }
            },
            {
                "colorattachments": [1],
                "samplers": [0],
                "mipLevel": 2,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomBlurY.frag.spv"
                    }
                }
            },  

            {
                "samplers": ["PREVPASS", 1],
                "mipLevel": 0,
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/BloomResolve.frag.spv"
                    }
                }
            }                      
        ]
    }
}