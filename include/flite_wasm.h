/*************************************************************************/
/*                                                                       */
/*    Rust-c interface for wasm32-unknown-unknown.                       */
/*                                                                       */
/*       Authors:  Bryan Jimenez                                         */
/*          Date:  Dec 2024                                              */
/*************************************************************************/

typedef struct  result_wave_struct {
    int sample_rate;
    int num_samples;
    int num_channels;
    short *samples;
} result_wave;

/* Wasm Exported*/
result_wave* synth_audio_basic(const char *text);
