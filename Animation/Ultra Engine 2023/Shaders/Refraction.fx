{
    "posteffect":
    {
        "premultiplyAlpha": true,
        "subpasses":
        [
            {
                "samplers": ["PREVPASS", "DEPTH", "TRANSPARENCY_NORMAL", "TRANSPARENCY", "METALLICROUGHNESS", "ZPOSITION", "ALBEDO"],
                "shader":
                {
                    "float32":
                    {
                        "fragment": "Shaders/Refraction.frag.spv"
                    }
                }
            }              
        ]
    }
}
