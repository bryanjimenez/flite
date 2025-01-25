/*************************************************************************/
/*                                                                       */
/*    Rust-c entry-point for wasm32-unknown-unknown.                     */
/*                                                                       */
/*       Authors:  Bryan Jimenez                                         */
/*          Date:  Dec 2024                                              */
/*************************************************************************/

#include "cst_synth.h"
#include "flite_wasm.h"

#ifdef CST_DEBUG_MALLOC
void cst_alloc_debug_summary(void);
#endif

#define WASM_EXPORT __attribute__((visibility("default")))

/* ../lang/cmu_us_kal/cmu_us_kal.c */
cst_voice *register_cmu_us_kal(const char *voxdir);
/* ../lang/cmu_us_slt/cmu_us_slt.c */
cst_voice *register_cmu_us_slt(const char *voxdir);

// Expose mechanism to deallocate cached voice
#ifdef VALGRIND_TEST
cst_voice *selected_voice = NULL;

int WASM_EXPORT deallocate_voice(){
    delete_voice(selected_voice);

// use Flite's built-in malloc usage summary
#ifdef CST_DEBUG_MALLOC
    rust_print_msg("flite CST_DEBUG_MALLOC: ");
    cst_alloc_debug_summary();
#endif
    return 0;
}
#endif /* VALGRIND_TEST */

result_wave* WASM_EXPORT synth_audio(const char *text, unsigned short voice_type){

    cst_voice *voice = NULL;
    switch (voice_type) {
        case 0:
            voice = register_cmu_us_kal(NULL);
            break;
        case 1:
            voice = register_cmu_us_slt(NULL);
            break;
        default:
            voice = register_cmu_us_kal(NULL);
    }

    #ifdef VALGRIND_TEST
    selected_voice = voice;
    #endif /* VALGRIND_TEST */

    cst_utterance *u = new_utterance();
    feat_set_string(u->features,"input_text",text);
    utt_init(u, voice);

    if ((*utt_synth)(u) == NULL)
    {
        delete_utterance(u);
        return NULL;
    }

    cst_wave *w= val_wave(feat_val(u->features,"wave"));
    result_wave *o = (result_wave*)alloc_result_wave(w->num_channels, w->sample_rate, w->num_samples, w->samples);

    // delete_utterance performs delete_wave(w);
    delete_utterance(u);
    return o;
}
