format PE console
;------------------------------------------------------------------------------------------------------------------
;Кочик Дмитрий Алексеевич
;БПИ199
;Вариант 11
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

        call countSum         ; Вычисляем примерное значение дзета-функции Римана для s=2.
        call countPiVal       ; Зная примерное значение ф-ии, вычисляем примерное значение числа пи.
        call getAnswer        ; Выводим ответ.

        invoke getch
        invoke ExitProcess    ; Завершаем выполнение программы.
;------------------------------------------------------------------------------------------------------------------
    countSum:
        mov [pos], esp        ; Запоминаем позиция функции в стеке при вызове.

    startCycle:               ; Начинаем цикл для подсчета дзета-функции Римана.
        FLD [sum]
        FSTP [curr_num2]      ; Запоминаем старое значение суммы.


        FILD [counter]
        FST [curr_num]
        FMUL [curr_num]
        FSTP [curr_num]      ; Вычисляем i-й элемент суммы.

        FLD1
        FDIV [curr_num]      ; i-й элемент равен 1/(i^2).
        FADD [sum]
        FSTP [sum]           ; Обновляем значение суммы.

        mov eax, [counter]
        inc eax
        mov [counter], eax   ; увеличиваем счетчик итераций цикла.

        FLD [curr_num2]
        FDIV [sum]
        FCOMP [coef]         ; Если отношение суммы предыдущей итерации и текущей больше чем 0.1%
        jge startCycle       ; Продолжаем выполнение цикла.

    finish:
        mov esp, [pos]       ; Иначе прекращаем выполнение.
        ret
;------------------------------------------------------------------------------------------------------------------
    countPiVal:
        mov [pos], esp       ; Запоминаем позиция функции в стеке при вызове.

        invoke printf, raw_result, dword[sum], dword[sum+4]  ; Выводим информацию о вычисленном значении дзета-функции Римана при s=2.
                             ; sum = Pi^2/6
        FLD [sum]
        FMUL [coef_pi_counting]  ; Умножаем сумму на 6.
        FST [sum]
        invoke printf, raw_result2, dword[sum], dword[sum+4] ; Выводим информацию о вычисленном значении дзета-функции Римана при s=2, умноженной на 6.
        FSQRT
        FSTP [sum]          ; Вычисляем корень из sum*6. Это и есть число пи.

        mov esp, [pos]
        ret
;------------------------------------------------------------------------------------------------------------------
    getAnswer:
        mov [pos], esp      ; Запоминаем позиция функции в стеке при вызове.

        invoke printf, res, dword[sum], dword[sum+4]                      ; Выводим информацию о том, что нам удалось вычислить.

        FLDPI
        FST [answer_val]
        invoke printf, answer, dword[answer_val], dword[answer_val+4]     ; Выводим правильный ответ для сравнения.

        FLD [sum]
        FSUB [answer_val]
        FIMUL [sth]
        FSTP [answer_val]

        invoke printf, inaccuracy, dword[answer_val], dword[answer_val+4]  ; Выводим полученную погрешность.

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