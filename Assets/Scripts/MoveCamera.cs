using UnityEngine;

public class MoveCamera : MonoBehaviour
{
    [SerializeField] float speed = 1;
    [SerializeField] Transform endPos;
    bool moveToEnd = false;
    float stepCollection;

    private Vector3 startPos;

    void Start()
    {
        startPos = new Vector3(transform.position.x, transform.position.y, transform.position.z);
    }

    void Update()
    {
        if (moveToEnd)
        {
            stepCollection += Time.deltaTime * speed;
            if (stepCollection > 1)
                moveToEnd = false;
        }
        else
        {
            stepCollection -= Time.deltaTime * speed;
            if (stepCollection < 0)
                moveToEnd = true;
        }

        transform.position = Vector3.Lerp(startPos, endPos.position, stepCollection);
    }
}
