{
    "posteffect":
    {
        "subpasses":
        [
            {    
                "samplers": ["PREVPASS"],
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/FXAA.frag.spv"
                    }
                }
            }
        ]
    }
}