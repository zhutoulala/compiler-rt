//===-- aeabi_cfcmp.S - EABI cfcmp* implementation ------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is dual licensed under the MIT and the University of Illinois Open
// Source Licenses. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

#if __BYTE_ORDER__ != __ORDER_LITTLE_ENDIAN__
#error big endian support not implemented
#endif

#define APSR_Z (1 << 30)
#define APSR_C (1 << 29)

// void __aeabi_cfcmpeq(float a, float b) {
//   if (isnan(a) || isnan(b)) {
//     Z = 0; C = 1;
//   } else {
//     __aeabi_cfcmple(a, b);
//   }
// }

        .syntax unified
        .p2align 2
DEFINE_COMPILERRT_FUNCTION(__aeabi_cfcmpeq)
        push {r0-r3, lr}
        bl __aeabi_cfcmpeq_check_nan
        cmp r0, #1
#if defined(USE_THUMB_1)
        beq 1f
        // NaN has been ruled out, so __aeabi_cfcmple can't trap
        mov r0, sp
        ldm r0, {r0-r3}
        bl __aeabi_cfcmple
        pop {r0-r3, pc}
1:
        // Z = 0, C = 1
        movs r0, #0xF
        lsls r0, r0, #31
        pop {r0-r3, pc}
#else
        pop {r0-r3, lr}

        // NaN has been ruled out, so __aeabi_cfcmple can't trap
        bne __aeabi_cfcmple

#if defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7EM__)
        mov ip, #APSR_C
        msr APSR_nzcvq, ip
#else
        msr CPSR_f, #APSR_C
#endif
        JMP(lr)
#endif
END_COMPILERRT_FUNCTION(__aeabi_cfcmpeq)


// void __aeabi_cfcmple(float a, float b) {
//   if (__aeabi_fcmplt(a, b)) {
//     Z = 0; C = 0;
//   } else if (__aeabi_fcmpeq(a, b)) {
//     Z = 1; C = 1;
//   } else {
//     Z = 0; C = 1;
//   }
// }

        .syntax unified
        .p2align 2
DEFINE_COMPILERRT_FUNCTION(__aeabi_cfcmple)
        // Per the RTABI, this function must preserve r0-r11.
        // Save lr in the same instruction for compactness
        push {r0-r3, lr}

        bl __aeabi_fcmplt
        cmp r0, #1
#if defined(USE_THUMB_1)
        bne 1f
        // Z = 0, C = 0
        movs r0, #1
        lsls r0, r0, #1
        pop {r0-r3, pc}
1:
        mov r0, sp
        ldm r0, {r0-r3}
        bl __aeabi_fcmpeq
        cmp r0, #1
        bne 2f
        // Z = 1, C = 1
        movs r0, #2
        lsls r0, r0, #31
        pop {r0-r3, pc}
2:
        // Z = 0, C = 1
        movs r0, #0xF
        lsls r0, r0, #31
        pop {r0-r3, pc}
#else
        ITT(eq)
        moveq ip, #0
        beq 1f

        ldm sp, {r0-r3}
        bl __aeabi_fcmpeq
        cmp r0, #1
        ITE(eq)
        moveq ip, #(APSR_C | APSR_Z)
        movne ip, #(APSR_C)

1:
#if defined(__ARM_ARCH_7M__) || defined(__ARM_ARCH_7EM__)
        msr APSR_nzcvq, ip
#else
        msr CPSR_f, ip
#endif
        pop {r0-r3}
        POP_PC()
#endif
END_COMPILERRT_FUNCTION(__aeabi_cfcmple)

// int __aeabi_cfrcmple(float a, float b) {
//   return __aeabi_cfcmple(b, a);
// }

        .syntax unified
        .p2align 2
DEFINE_COMPILERRT_FUNCTION(__aeabi_cfrcmple)
        // Swap r0 and r1
        mov ip, r0
        mov r0, r1
        mov r1, ip

        b __aeabi_cfcmple
END_COMPILERRT_FUNCTION(__aeabi_cfrcmple)

NO_EXEC_STACK_DIRECTIVE

