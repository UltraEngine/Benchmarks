{
    "posteffect":
    {
        "subpasses":
        [
            {    
                "samplers": ["DEPTH"],
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/WireframeSelection.frag.spv"
                    }
                }
            }
        ]
    }
}