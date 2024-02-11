using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using UnityEngine;

public class TestSequencer : MonoBehaviour
{
    [SerializeField] CsoundUnity _csound;

    [SerializeField] TicksDivision _ticks = TicksDivision.Sixteenth;
    [SerializeField] int _numberOfBars = 16;

    [SerializeField] Set[] _sets;

    [SerializeField] int _currentSet = 0;
    [SerializeField] string _currentScale = Scale.PentatonicMinor;

    private float _leadNoteMin;
    private float _leadNoteMax;
    private float _leadWaveMin;
    private float _leadWaveMax;
    private float _filtFreqMin;
    private float _filtFreqMax;
    private float _filtResMin;
    private float _filtResMax;
    private float _filtLFOFreqMin;
    private float _filtLFOFreqMax;

    IEnumerator Start()
    {
        while (!_csound.IsInitialized)
        {
            yield return null;
        }

        _csound.SetChannel("tickSteps", (int)_ticks);
        _csound.SetChannel("bars", _numberOfBars);
        _csound.SendScoreEvent($"i\"UPDATE_SCALE\" 0 0.1 \"{_currentScale}\"");

        yield return SendSequencesFromSet(_sets[_currentSet], 0.00f);

        _leadNoteMin = _csound.GetChannelController("leadNote").min;
        _leadNoteMax = _csound.GetChannelController("leadNote").max;
        _leadWaveMin = _csound.GetChannelController("leadWave").min;
        _leadWaveMax = _csound.GetChannelController("leadWave").max;
        _filtFreqMin = _csound.GetChannelController("leadFiltFreq").min;
        _filtFreqMax = _csound.GetChannelController("leadFiltFreq").max;
        _filtResMin = _csound.GetChannelController("leadFiltRes").min;
        _filtResMax = _csound.GetChannelController("leadFiltRes").max;
        _filtLFOFreqMin = _csound.GetChannelController("leadFiltLFOFreq").min;
        _filtLFOFreqMax = _csound.GetChannelController("leadFiltLFOFreq").max;

        Debug.Log($"_leadNoteMin: {_leadNoteMin}, _leadNoteMax: {_leadNoteMax}");

        yield return new WaitForSeconds(1f);
        _csound.SendScoreEvent("i\"INITIALIZATION\" 0 1");
        yield return new WaitForSeconds(1f);
        _csound.SendScoreEvent("i\"GENERATOR\" 0 -1");
    }

    IEnumerator SendSequencesFromSet(Set set, float waitInterval)
    {
        Debug.Log($"Sending set[{_currentSet}]: {set.name}");
        if (set.Melody.steps.Count != set.TenseMelody.steps.Count)
        {
            Debug.LogError("Melody and tense Melody steps cannot have different sizes!");
            yield break;
        }
        if (set.Melody.ticks != set.TenseMelody.ticks)
        {
            Debug.LogError("Melody and tense Melody cannot have different tick sizes!");
            yield break;
        }

        if (set.Bass.steps.Count != set.TenseBass.steps.Count)
        {
            Debug.LogError("Bass and Tense Bass steps cannot have different sizes!");
            yield break;
        }
        if (set.Bass.ticks != set.TenseBass.ticks)
        {
            Debug.LogError("Bass and Tense Bass cannot have different tick sizes!");
            yield break;
        }

        if (set.Rhythm.steps.Count != set.TenseRhythm.steps.Count)
        {
            Debug.LogError("Rhythm and Tense Rhythm steps cannot have different sizes!");
            yield break;
        }
        if (set.Rhythm.ticks != set.TenseRhythm.ticks)
        {
            Debug.LogError("Rhythm and Tense Rhythm cannot have different tick sizes!");
            yield break;
        }

        if (set.Chords.steps.Count != set.TenseChords.steps.Count)
        {
            Debug.LogError("Chords and Tense Chords steps cannot have different sizes!");
            yield break;
        }
        if (set.Chords.ticks != set.TenseChords.ticks)
        {
            Debug.LogError("Chords and Tense Chords cannot have different tick sizes!");
            yield break;
        }

        // send melodies to Csound
        _csound.SetChannel(set.Melody.channel + "Ticks", (int)set.Melody.ticks);
        _csound.SetStringChannel(set.Melody.channel, CreateStringFromSequence(set.Melody));
        yield return new WaitForSeconds(waitInterval);
        _csound.SetStringChannel(set.TenseMelody.channel, CreateStringFromSequence(set.TenseMelody));
        yield return new WaitForSeconds(waitInterval);

        // send bass
        _csound.SetChannel(set.Bass.channel + "Ticks", (int)set.Bass.ticks);
        _csound.SetStringChannel(set.Bass.channel, CreateStringFromSequence(set.Bass));
        yield return new WaitForSeconds(waitInterval);
        _csound.SetStringChannel(set.TenseBass.channel, CreateStringFromSequence(set.TenseBass));
        yield return new WaitForSeconds(waitInterval);

        // send rhythms
        _csound.SetChannel(set.Rhythm.channel + "Ticks", (int)set.Rhythm.ticks);
        _csound.SetStringChannel(set.Rhythm.channel, CreateStringFromSequence(set.Rhythm));
        yield return new WaitForSeconds(waitInterval);
        _csound.SetStringChannel(set.TenseRhythm.channel, CreateStringFromSequence(set.TenseRhythm));
        yield return new WaitForSeconds(waitInterval);

        // send chords
        _csound.SetChannel(set.Chords.channel + "Ticks", (int)set.Chords.ticks);
        _csound.SetStringChannel(set.Chords.channel, CreateStringFromSequence(set.Chords));
        yield return new WaitForSeconds(waitInterval);
        _csound.SetStringChannel(set.TenseChords.channel, CreateStringFromSequence(set.TenseChords));
        yield return new WaitForSeconds(waitInterval);

        // initialise sequences
        _csound.SendScoreEvent("i\"INITIALIZATION\" 0 1");
    }

    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            _csound.SendScoreEvent("i1 0 -1");
        }
        if (Input.GetMouseButtonUp(0))
        {
            _csound.SendScoreEvent("i-1 0 -1");
        }
        if (Input.GetMouseButton(0))
        {
            _csound.SetChannel("leadNote", CsoundUnity.Remap(Input.mousePosition.y, 0, Screen.height, _leadNoteMin, _leadNoteMax, true));
            _csound.SetChannel("leadWave", CsoundUnity.Remap(Input.mousePosition.x, 0, Screen.width, _leadWaveMin, _leadWaveMax, true));
        }
        if (Input.GetKey(KeyCode.LeftShift) || Input.GetKey(KeyCode.RightShift))
        {
            _csound.SetChannel("leadFiltFreq", CsoundUnity.Remap(Input.mousePosition.y, 0, Screen.height, _filtFreqMin, _filtFreqMax, true));
        }

        if (Input.GetMouseButton(1))
        {
            var value = CsoundUnity.Remap(Input.mousePosition.x, 0, Screen.width, 0, 1, true);
            _csound.SetChannel("state", value);
        }

        if (Input.GetKeyDown(KeyCode.M))
        {
            _csound.SetChannel("stateMode", _csound.GetChannel("stateMode") == 1 ? 0 : 1);
        }

        if (Input.GetKey(KeyCode.LeftControl) || Input.GetKey(KeyCode.RightControl))
        {
            _csound.SetChannel("leadFiltLFOFreq", CsoundUnity.Remap(Input.mousePosition.x, 0, Screen.width, _filtLFOFreqMin, _filtLFOFreqMax, true));
        }

        #region SCALES

        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            SetCurrentScale(Scale.Major); 
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            SetCurrentScale(Scale.Minor);
        }
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            SetCurrentScale(Scale.PentatonicMinor);
        }
        if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            SetCurrentScale(Scale.HarmonicMinor);
        }
        if (Input.GetKeyDown(KeyCode.Alpha5))
        {
            SetCurrentScale(Scale.MelodicMinorAsc);
        }
        if (Input.GetKeyDown(KeyCode.Alpha6))
        {
            SetCurrentScale(Scale.Blues);
        }
        if (Input.GetKeyDown(KeyCode.Alpha7))
        {
            SetCurrentScale(Scale.PentatonicMajor);
        }
        if (Input.GetKeyDown(KeyCode.Alpha8))
        {
            SetCurrentScale(Scale.Locrian);
        }
        if (Input.GetKeyDown(KeyCode.Alpha9))
        {
            SetCurrentScale(Scale.Dorian);
        }
        if (Input.GetKeyDown(KeyCode.Alpha0))
        {
            SetCurrentScale(Scale.Phryigian);
        }
        if (Input.GetKeyDown(KeyCode.LeftShift) || Input.GetKeyDown(KeyCode.RightShift))
        {
            if (Input.GetKeyDown(KeyCode.Alpha1))
            {
                SetCurrentScale(Scale.Lydian); 
            }
            if (Input.GetKeyDown(KeyCode.Alpha2))
            {
                SetCurrentScale(Scale.Mixolydian);
            }
        }
        #endregion SCALES

        #region SEQUENCES

        if (Input.GetKeyDown(KeyCode.A))
        {
           StartCoroutine(SendSequencesFromSet(_sets[(++_currentSet) % _sets.Length], 0.1f));
        }
        if (Input.GetKeyDown(KeyCode.R)) // reload current set
        {
            StartCoroutine(SendSequencesFromSet(_sets[_currentSet % _sets.Length], 0.1f));
        }
        #endregion SEQUENCES
    }

    private static string CreateStringFromSequence(Sequence sequence)
    {
        var res = String.Empty;
        foreach (var step in sequence.steps)
        {
            foreach (var note in step.notes)
            {
                var n = note.number.ToString().Replace(",", ".");
                var v = note.volume.ToString().Replace(",", ".");
                var d = note.duration.ToString().Replace(",", ".");

                res += $"{n},{v},{d}:";
            }
            res += "_";
        }
        Debug.Log($"{sequence.channel}: {res}");
        return res;
    }

    public void SetCurrentScale(string scale)
    {
        Debug.Log($"Setting scale: {scale}");
        _currentScale = scale;
        _csound.SendScoreEvent($"i\"UPDATE_SCALE\" 0 0.1 \"{_currentScale}\"");
    }
}

