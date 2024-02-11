using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Set", menuName = "AR Synth/Create new set", order = 1)]

public class Set : ScriptableObject
{
    public Sequence Melody;
    public Sequence TenseMelody;
    public Sequence Bass;
    public Sequence TenseBass;
    public Sequence Rhythm;
    public Sequence TenseRhythm;
    public Sequence Chords;
    public Sequence TenseChords;
}
