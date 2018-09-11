using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VertexSetter : MonoBehaviour
{
    public Material mat;

    // Use this for initialization
    void Start()
    {

    }


    private void OnDrawGizmos()
    {
        if (mat == null) { return; }
        mat.SetVector("_VectorPos", transform.position);

    }

    // Update is called once per frame
    void Update()
    {

    }
}
