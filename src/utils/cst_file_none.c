/*************************************************************************/
/*                                                                       */
/*    File I/O wrappers (and stubs) for wasm32-unknown-unknown.          */
/*                                                                       */
/*       Authors:  Bryan Jimenez                                         */
/*          Date:  Dec 2024                                              */
/*************************************************************************/

#include "flite_patch_stdio.h"
#include "flite_patch_string.h"
#include "flite_patch_stdarg.h"
#include "cst_file.h"
#include "cst_string.h"
#include "cst_error.h"
#include "cst_alloc.h"
#include "flite_patch_logging.h"

cst_file cst_fopen(const char *path, int mode)
{
  cst_file fh = NULL;
  unimplemented("cst_fopen");
  return fh;
}

long cst_fwrite(cst_file fh, const void *buf, long size, long count)
{
  unimplemented("cst_fwrite");
  return 0;
}

long cst_fread(cst_file fh, void *buf, long size, long count)
{
  unimplemented("cst_fread");
  return 0;
}

long cst_filesize(cst_file fh)
{
  unimplemented("cst_filesize");
  return 0;
}

int cst_fgetc(cst_file fh)
{
  unimplemented("cst_fgetc");
  return 0;
}

long cst_ftell(cst_file fh)
{
  unimplemented("cst_ftell");
  return 0;
}

long cst_fseek(cst_file fh, long pos, int whence)
{
  unimplemented("cst_fseek");
  return 0;
}

int cst_fprintf(cst_file fh, const char *fmt, ...)
{
  unimplemented("cst_fprintf");
  return 0;
}

int cst_int_to_ascii(char* string, int number){
    int write_len = 0;

    if(number<0){
        // negative sign
        string[write_len] = (char)(45);
        number *= -1;
        write_len++;
    }

    int dec_places = -1;
    while (dec_places<0) {
        if(number / (-dec_places) < 1){
            dec_places /= -10;
        } else {
            dec_places *= 10;
        }
    }

    int digit = 0;
    while(dec_places>0) {
        digit = number / dec_places;
        string[write_len] = (char)(digit + 48); // int to ascii number

        number -= (dec_places * digit);
        dec_places /= 10;
        write_len++;
    }

    return write_len;
}

int cst_sprintf(char *s, const char *fmt, ...){
    va_list arguments;

    int pattern_type = -1;
    int p_pos = 0;
    char* p = (char*) fmt;
    int p_num = -1;

    char one_char[1];
    int pad_a_len = -1;
    int pad_b_len = -1;
    char pad_a_buf[16];
    char pad_b_buf[16];
    char content[128];

    char *errMsg = "cst_sprintf: Unknown type ";
    char err[64];
    strcpy(err, errMsg);

    va_start(arguments, fmt);

    do {
        // [](src/lexicon/cst_lts.c#L130)
        if(strcmp(fmt,"%.*s#%s#%.*s")==0){
            pattern_type = 1;
            if(p_pos==1){
                pad_a_len = p_num;
            } else if(p_pos==2){
                strcpy(pad_a_buf, p);
            } else if(p_pos==3){
                strcpy(content, p);
            } else if(p_pos==4){
                pad_b_len = p_num;
            } else if(p_pos==5){
                strcpy(pad_b_buf, p);
            }
        // [](src/lexicon/cst_lts.c#L144)
        } else if(strcmp(fmt,"%.*s%.*s%s")==0){
            pattern_type = 2;
            if(p_pos==1){
                pad_a_len = p_num;
            } else if(p_pos==2){
                strcpy(pad_a_buf, p);
            } else if(p_pos==3){
                pad_b_len = p_num;
            } else if(p_pos==4){
                strcpy(pad_b_buf, p);
            } else if(p_pos==5){
                strcpy(content, p);
            }
        } else if(strcmp(fmt,"%c%s")==0){
            pattern_type = 0;
            if (p_pos==1) {
                // sprintf(one_char,"%c",p);
            } else if(p_pos==2){
                strcpy(content, p);
            }
        // [](src/lexicon/cst_lts.c#L96)
        } else if(strcmp(fmt,"%.10s-%.10s")==0){
            pattern_type = 3;
            if (p_pos==1) {
                pad_a_len = strlen(p);
                if(pad_a_len>10){
                    pad_a_len = 10;
                }
                strcpy(pad_a_buf, p);
            } else if(p_pos==2){
                pad_b_len = strlen(p);
                if(pad_b_len>10){
                    pad_b_len = 10;
                }
                strcpy(pad_b_buf, p);
            }
        } else if(strcmp(fmt,"%.10s_-_%.10s")==0) {
            pattern_type = 4;
            if (p_pos==1) {
                pad_a_len = strlen(p);
                if(pad_a_len>10){
                    pad_a_len = 10;
                }
                strcpy(pad_a_buf, p);
            } else if(p_pos==2){
                pad_b_len = strlen(p);
                if(pad_b_len>10){
                    pad_b_len = 10;
                }
                strcpy(pad_b_buf, p);
            }
        } else if(strcmp(fmt,"%s%s")==0) {
          pattern_type = 5;
          if (p_pos==1) {
            strcpy(content, p);
          } else if(p_pos==2){
            strcat(content, p);
          }
        } else if(strcmp(fmt,"%s%s%s")==0) {
          pattern_type = 6;
          if (p_pos==1) {
            strcpy(content, p);
          } else if(p_pos==2 || p_pos==3) {
            strcat(content, p);
          }
        } else if(strcmp(fmt,"%d")==0) {
          pattern_type = 7;
        }


        if(
        (pattern_type==2 && (p_pos==0 || p_pos==2))
        ||
        (pattern_type==1 && (p_pos==0 || p_pos==3))) {
            // The argument is numeric
            p_num = va_arg(arguments, int);
        } else if (pattern_type==7){
            // The argument is numeric
            p_num = va_arg(arguments, int);
            p = NULL;
        } else if (pattern_type==0 && p_pos==0){
            // The argument is a character
            one_char[0] = (unsigned char)va_arg(arguments, unsigned int);
        } else {
            // The argument is string
            p = va_arg(arguments, char*);
        }

        p_pos++;

    } while (p!=NULL);

    va_end(arguments);

    int write_len = 0;
    switch (pattern_type) {
        case 0:
            // "%c%s"
            __builtin_memmove(s, one_char, 1);
            __builtin_memmove(s+1, content, strlen(content));
            write_len = 1 + strlen(content);
            break;
        case 1:
            // "%.*s#%s#%.*s"
            __builtin_memmove(s, pad_a_buf, pad_a_len);
            __builtin_memmove(s+pad_a_len, "#", 1);
            __builtin_memmove(s+pad_a_len+1, content, strlen(content));
            __builtin_memmove(s+pad_a_len+1+strlen(content), "#", 1);
            __builtin_memmove(s+pad_a_len+1+strlen(content)+1, pad_b_buf, pad_b_len);
            write_len = pad_a_len + 1 + strlen(content) + 1 + pad_b_len;
            break;
        case 2:
            // "%.*s%.*s%s"
            __builtin_memmove(s, pad_a_buf, pad_a_len);
            __builtin_memmove(s+pad_a_len, pad_b_buf, pad_b_len);
            __builtin_memmove(s+pad_a_len+pad_b_len, content, strlen(content));
            write_len = pad_a_len + pad_b_len + strlen(content);
            break;
        case 3:
            // "%.10s-%.10s"
            __builtin_memmove(s, pad_a_buf, pad_a_len);
            __builtin_memmove(s+pad_a_len, "-", 1);
            __builtin_memmove(s+pad_a_len+1, pad_b_buf, pad_b_len);
            write_len = pad_a_len + 1 + pad_b_len;
            break;
        case 4:
            // "%.10s_-_%.10s"
            __builtin_memmove(s, pad_a_buf, pad_a_len);
            __builtin_memmove(s+pad_a_len, "_-_", 3);
            __builtin_memmove(s+pad_a_len+3, pad_b_buf, pad_b_len);
            write_len = pad_a_len + 3 + pad_b_len;
            break;
        case 5:
            // "%s%s"
            __builtin_memmove(s, content, strlen(content));
            write_len = strlen(content);
            break;
        case 6:
            // "%s%s%s"
            __builtin_memmove(s, content, strlen(content));
            write_len = strlen(content);
            break;
        case 7:
            // "%d"
            write_len = cst_int_to_ascii(s, p_num);
            break;
        default:
            strcat(err, fmt);
            log_to_js(err);
            WASM_PATCH_exit(-99);
    }

    s[write_len] = '\0';
    return write_len;
}

int cst_fclose(cst_file fh)
{
  unimplemented("cst_fclose");
  return 0;
}
