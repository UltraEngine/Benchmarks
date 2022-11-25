using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubePrefabLoader : MonoBehaviour
{
    public GameObject cubePrefab;
    public Vector3Int numBoxes = new Vector3Int(48, 48, 48),
                      boxSpacing = new Vector3Int(1, 1, 1);
    public int boxSize = 1;

    void Start()
    {
        float xOffset = (numBoxes.x - 1) * (boxSize + boxSpacing.x) * -0.5f;
        float yOffset = (numBoxes.y - 1) * (boxSize + boxSpacing.y) * -0.5f;
        float zOffset = (numBoxes.z - 1) * (boxSize + boxSpacing.z) * -0.5f;

        float xPos = 0, yPos = 0, zPos = 0;
        int i = 0;
        for (int x = 0; x < numBoxes.x; x++)
        {
            if (x > 0)
            {
                xPos = x * (boxSize + boxSpacing.x) + xOffset;
            }
            else
            {
                xPos = xOffset;
            }

            for (int y = 0; y < numBoxes.y; y++)
            {
                if (y > 0)
                {
                    yPos = y * (boxSize + boxSpacing.y) + yOffset;
                }
                else
                {
                    yPos = yOffset;
                }

                for (int z = 0; z < numBoxes.z; z++)
                {
                    if (z > 0)
                    {
                        zPos = z * (boxSize + boxSpacing.z) + zOffset;
                    }
                    else
                    {
                        zPos = zOffset;
                    }

                    Instantiate(cubePrefab, new Vector3(xPos, yPos, zPos), Quaternion.identity);
                    i++;
                }
            }
        }
    }
}