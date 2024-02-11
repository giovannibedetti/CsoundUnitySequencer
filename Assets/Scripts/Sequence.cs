using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Sequence", menuName = "AR Synth/Create new sequence", order = 1)]
public class Sequence : ScriptableObject
{
    public string channel;
    public TicksDivision ticks = TicksDivision.Sixteenth;
    public List<Step> steps;
}

[Serializable]
public class Note
{
    public int number;
    public float volume;
    public float duration; // relative to speed
}

[Serializable]
public class Step
{
    public List<Note> notes;
}
