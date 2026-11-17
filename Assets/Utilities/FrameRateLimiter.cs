using UnityEngine;

public class FrameRateLimiter : MonoBehaviour
{
    public int targetFrameRate = 60;
    public bool runInBackground = true;
    
    public void Start()
    {
        Debug.Log($"Apply targetFrameRate to {targetFrameRate}");
        Debug.Log($"Apply runInBackground to {runInBackground}");
        Application.targetFrameRate = targetFrameRate;
        Application.runInBackground = runInBackground;
    }
}
