using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotator : MonoBehaviour
{
    public Rigidbody rb;
    private Vector3 rotateAmount;
    // Start is called before the first frame update
    void Start()
    {
        rb = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        rotateAmount = new Vector3(0.0f, 10.0f, 0.0f);

        Quaternion deltaRotation = Quaternion.Euler(rotateAmount * Time.fixedDeltaTime);
        rb.MoveRotation(rb.rotation * deltaRotation);
    }
}
