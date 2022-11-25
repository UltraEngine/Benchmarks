using UnityEngine;
using UnityEngine.UI;
 
public class FPS : MonoBehaviour
{
    public int avgFrameRate;
    public Text display_Text;
 
    public void Update ()
    {
        float current = 0;
        current = Time.frameCount / Time.time;
        avgFrameRate = (int)current;
        display_Text.text = avgFrameRate.ToString() + " FPS";
    }
}