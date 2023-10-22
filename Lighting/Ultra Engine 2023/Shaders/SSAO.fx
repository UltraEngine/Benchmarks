{
    "posteffect":
    {
        "parameters":
        [
            {
                "name": "Samples",
                "value": 16
            }
        ],
        "textures":
        [
            {
                "size": [0.5,0.5],
                "format": 9
            },
            {
                "size": [0.5,0.5],
                "format": 9
            }            
        ],
        "subpasses":
        [
            {
                "samplers": ["ZPOSITION", "NORMAL", "PREVPASS"],
                "colorattachments": [0],
                "shader":
                {
                    "float32":
                    {                    
                        "fragment": "Shaders/SSAO.frag.spv"
                    }
                }
            },
            {
                "samplers": [0, "ZPOSITION"],
                "colorattachments": [1],
                "shader":
                {
                    "float32":
                    {                    
                        "fragment": "Shaders/Denoise.frag.spv"
                    }
                }
            },            
            {
                "samplers": ["PREVPASS", "ZPOSITION", 1],
                "shader":
                {
                    "float32":
                    {                    
                        "fragment": "Shaders/SSAOResolve.frag.spv"
                    }
                }
            }            
        ]
    }
}