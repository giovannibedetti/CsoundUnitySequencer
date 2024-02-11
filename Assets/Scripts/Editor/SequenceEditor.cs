using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(Sequence))]
public class SequenceEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();

        var sequence = (Sequence)target;

        if (GUILayout.Button("Duplicate Steps"))
        {
            DuplicateSteps(sequence);
        }
    }

    private void DuplicateSteps(Sequence sequence)
    {
        var length = sequence.steps.Count;
        var newLength = length * 2;
        var newSteps = new List<Step>();

        for (var i = 0; i < newLength; i++)
        {
            var step = new Step
            {
                notes = sequence.steps[i % length].notes
            };
            newSteps.Add(step);
        }

        sequence.steps = newSteps;
        EditorUtility.SetDirty(sequence);
        AssetDatabase.SaveAssets();
    }
}
