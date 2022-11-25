using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class BoxBuilder : MonoBehaviour
{
    private GameObject[] boxes;

    void Start () {

        int count = 64;
        Array.Resize(ref boxes,count*count*count);
        int n=0;    

        for (int x = 1; x <= count; x++)
        {
        for (int y = 1; y <= count; y++)
        {
        for (int z = 1; z <= count; z++)
        {
            boxes[n] = new GameObject();
            boxes[n].AddComponent<MeshFilter>();
            boxes[n].AddComponent<MeshRenderer>();

            boxes[n].transform.position = new Vector3((x-(count/2+1))*2, (y-(count/2+1))*2, (z-(count/2+1))*2);;//new Vector3(x-(count/2+1)*2, y-(count/2+1)*2, z-(count/2+1)*2);

            Vector3[] vertices = {
                new Vector3 (-0.5f, -0.5f, -0.5f),
                new Vector3 (0.5f, -0.5f, -0.5f),
                new Vector3 (0.5f, 0.5f, -0.5f),
                new Vector3 (-0.5f, 0.5f, -0.5f),
                new Vector3 (-0.5f, 0.5f, 0.5f),
                new Vector3 (0.5f, 0.5f, 0.5f),
                new Vector3 (0.5f, -0.5f, 0.5f),
                new Vector3 (-0.5f, -0.5f, 0.5f),
            };

            int[] triangles = {
                0, 2, 1, //face front
                0, 3, 2,
                2, 3, 4, //face top
                2, 4, 5,
                1, 2, 5, //face right
                1, 5, 6,
                0, 7, 4, //face left
                0, 4, 3,
                5, 4, 7, //face back
                5, 7, 6,
                0, 6, 7, //face bottom
                0, 1, 6
            };
            
            Mesh mesh = boxes[n].GetComponent<MeshFilter> ().mesh;
            mesh.Clear ();
            mesh.vertices = vertices;
            mesh.triangles = triangles;
            mesh.Optimize ();
            mesh.RecalculateNormals ();
            n++;
        }
        }
        }
	}
}
