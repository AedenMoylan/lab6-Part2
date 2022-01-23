using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class GruadHelper : MonoBehaviour
{

    public GameObject Light;

    private void Start()
    {
        //Get the light source
        Light = GameObject.Find("Point Light");
    }

    // Update is called once per frame
    void Update()
    {
        //Get material    
        MeshRenderer mr = GetComponent<MeshRenderer>();
        //Pass the position information of the light source to the material, which is our Gouraud Shader
        mr.sharedMaterial.SetVector("_LightPos", Light.transform.position);

        Debug.Log(Light.transform.position);
    }
}