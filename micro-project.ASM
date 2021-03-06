format PE console
;------------------------------------------------------------------------------------------------------------------
;����� ������� ����������
;���199
;������� 11
;------------------------------------------------------------------------------------------------------------------
entry start
include 'win32a.inc'


section '.data' data readable writable
        sum                   dq 0.0
        curr_num              dq 0.0
        curr_num2             dq ?
        answer_val            dq ?
        coef                  dq 0.001
        coef_pi_counting      dq 6.0
        pos                   dd ?
        counter               dd 1
        sth                   dd 1000000

        raw_result            db "PI^2/6 is: %f",10 ,0
        raw_result2           db "PI^2 is: %f",10 ,0
        res                   db "The result is: %f",10 ,0
        answer                db "Correct answer is: %f", 10, 0
        inaccuracy            db "Inaccuracy is: %f*10^-6", 10, 0

        inf db "sth: %f", 10, 0

section '.code' code readable executable
    start:
        FINIT

        call countSum         ; ��������� ��������� �������� �����-������� ������ ��� s=2.
        call countPiVal       ; ���� ��������� �������� �-��, ��������� ��������� �������� ����� ��.
        call getAnswer        ; ������� �����.

        invoke getch
        invoke ExitProcess    ; ��������� ���������� ���������.
;------------------------------------------------------------------------------------------------------------------
    countSum:
        mov [pos], esp        ; ���������� ������� ������� � ����� ��� ������.

    startCycle:               ; �������� ���� ��� �������� �����-������� ������.
        FLD [sum]
        FSTP [curr_num2]      ; ���������� ������ �������� �����.


        FILD [counter]
        FST [curr_num]
        FMUL [curr_num]
        FSTP [curr_num]      ; ��������� i-� ������� �����.

        FLD1
        FDIV [curr_num]      ; i-� ������� ����� 1/(i^2).
        FADD [sum]
        FSTP [sum]           ; ��������� �������� �����.

        mov eax, [counter]
        inc eax
        mov [counter], eax   ; ����������� ������� �������� �����.

        FLD [curr_num2]
        FDIV [sum]
        FCOMP [coef]         ; ���� ��������� ����� ���������� �������� � ������� ������ ��� 0.1%
        jge startCycle       ; ���������� ���������� �����.

    finish:
        mov esp, [pos]       ; ����� ���������� ����������.
        ret
;------------------------------------------------------------------------------------------------------------------
    countPiVal:
        mov [pos], esp       ; ���������� ������� ������� � ����� ��� ������.

        invoke printf, raw_result, dword[sum], dword[sum+4]  ; ������� ���������� � ����������� �������� �����-������� ������ ��� s=2.
                             ; sum = Pi^2/6
        FLD [sum]
        FMUL [coef_pi_counting]  ; �������� ����� �� 6.
        FST [sum]
        invoke printf, raw_result2, dword[sum], dword[sum+4] ; ������� ���������� � ����������� �������� �����-������� ������ ��� s=2, ���������� �� 6.
        FSQRT
        FSTP [sum]          ; ��������� ������ �� sum*6. ��� � ���� ����� ��.

        mov esp, [pos]
        ret
;------------------------------------------------------------------------------------------------------------------
    getAnswer:
        mov [pos], esp      ; ���������� ������� ������� � ����� ��� ������.

        invoke printf, res, dword[sum], dword[sum+4]                      ; ������� ���������� � ���, ��� ��� ������� ���������.

        FLDPI
        FST [answer_val]
        invoke printf, answer, dword[answer_val], dword[answer_val+4]     ; ������� ���������� ����� ��� ���������.

        FLD [sum]
        FSUB [answer_val]
        FIMUL [sth]
        FSTP [answer_val]

        invoke printf, inaccuracy, dword[answer_val], dword[answer_val+4]  ; ������� ���������� �����������.

        mov esp, [pos]
        ret
;------------------------------------------------------------------------------------------------------------------
section '.idata' import data readable

    library kernel, 'kernel32.dll',\
            msvcrt, 'msvcrt.dll'

include 'api\user32.inc'
include 'api\kernel32.inc'
    import kernel,\
           ExitProcess, 'ExitProcess',\
           HeapCreate,'HeapCreate',\
           HeapAlloc,'HeapAlloc'
    import msvcrt,\
           printf, 'printf',\
           scanf, 'scanf',\
           getch, '_getch'