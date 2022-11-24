using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BoxSpawner : MonoBehaviour
{
    public Mesh cubeMesh;
    public Material cubeMaterial;
    public Vector3Int numBoxes = new Vector3Int(48, 48, 48),
                      boxSpacing = new Vector3Int(1, 1, 1);
    public int boxSize = 1;

    private int boxCount, cachedBoxCount = -1;
    private ComputeBuffer positionBuffer;
    private ComputeBuffer colorBuffer;
    private ComputeBuffer argsBuffer;
    private uint[] args = new uint[5] { 0, 0, 0, 0, 0 };
    private int xIndex = 0, yIndex = 0, zIndex = 0;
    private bool loaded;

    void Start()
    {
        boxCount = numBoxes.x * numBoxes.y * numBoxes.z;
        argsBuffer = new ComputeBuffer(1, args.Length * sizeof(uint), ComputeBufferType.IndirectArguments);
        UpdateBuffers();
        loaded = false;
    }

    private void Update()
    {
        if (!loaded)
        {
            if (cachedBoxCount != boxCount) UpdateBuffers();
            if (numBoxes.x < 0 || numBoxes.y < 0 || numBoxes.z < 0)
            {
                Debug.LogError("Invalid number of boxes.");
                return;
            }

            Graphics.DrawMeshInstancedIndirect(cubeMesh, 0, cubeMaterial,
                new Bounds(new Vector3(xIndex * boxSpacing.x, yIndex * boxSpacing.y, zIndex * boxSpacing.z),
                new Vector3(100.0f, 100.0f, 100.0f)), argsBuffer);

            xIndex++;
            if (xIndex >= numBoxes.x)
            {
                xIndex = 0;
                yIndex++;
            }

            if (yIndex >= numBoxes.y)
            {
                yIndex = 0;
                zIndex++;
            }

            if (zIndex >= numBoxes.z)
            {
                zIndex = 0;
                loaded = true;
            }
        }
    }

    void UpdateBuffers()
    {
        if (boxCount < 1) boxCount = 1;

        // Positions & Colors.
        if (positionBuffer != null) positionBuffer.Release();
        if (colorBuffer != null) colorBuffer.Release();

        positionBuffer = new ComputeBuffer(boxCount, 16);
        colorBuffer = new ComputeBuffer(boxCount, 4 * 4);

        Vector4[] positions = new Vector4[boxCount];
        Vector4[] colors = new Vector4[boxCount];

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

                    positions[i] = new Vector4(xPos, yPos, zPos, 1);
                    colors[i] = new Color(0.25f, 0.25f, 0.25f, 1);
                    i++;
                }
            }
        }

        positionBuffer.SetData(positions);
        colorBuffer.SetData(colors);

        cubeMaterial.SetBuffer("positionBuffer", positionBuffer);
        cubeMaterial.SetBuffer("colorBuffer", colorBuffer);

        // Indirect args.
        uint numIndices = (cubeMesh != null) ? (uint) cubeMesh.GetIndexCount(0) : 0;
        args[0] = numIndices;
        args[1] = (uint) boxCount;
        argsBuffer.SetData(args);

        cachedBoxCount = boxCount;
    }
}