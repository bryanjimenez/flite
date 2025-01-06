typedef struct  result_wave_struct {
    int sample_rate;
    int num_samples;
    int num_channels;
    short *samples;
} result_wave;

/* Wasm Exported*/
result_wave* synth_audio_basic(const char *text);
