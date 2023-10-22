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
                        "fragment": "Shaders/Outline.frag.spv"
                    }
                }
            }
        ]
    }
}