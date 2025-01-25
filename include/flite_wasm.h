/*************************************************************************/
/*                                                                       */
/*    Rust-c interface for wasm32-unknown-unknown.                       */
/*                                                                       */
/*       Authors:  Bryan Jimenez                                         */
/*          Date:  Dec 2024                                              */
/*************************************************************************/

typedef struct  result_wave_struct {
    unsigned int sample_rate;
    unsigned int num_samples;
    unsigned short num_channels;
    short *samples;
} result_wave;

/* Wasm Exported*/
result_wave* synth_audio(const char *text, unsigned short voice_type);

/* Valgrind test exported */
#ifdef CST_DEBUG_MALLOC
void rust_print_msg(const char *msg);
void rust_print_summary(
    int cst_allocated,
    int cst_freed,
    int cst_alloc_max,
    int cst_alloc_imax,
    int cst_alloc_num_calls,
    int cst_alloc_out
);
#endif
