using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class oscillatepos : MonoBehaviour
{
    Vector3 startpos;

    // Start is called before the first frame update
    void Start()
    {
        startpos = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        Vector3 offset;
        offset.y = startpos.y + Mathf.Sin(Time.time) * 3f;
        offset.x = startpos.x;
        offset.z = startpos.z;
        transform.position = offset;    
    }
}
