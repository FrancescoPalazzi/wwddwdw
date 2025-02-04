; multi-segment executable file template

data segment
    Vet1 dw 3 dup(?)  ; Definizione del primo vettore (3 elementi da 16 bit)
    Vet2 dw 3 dup(?)  ; Definizione del secondo vettore (3 elementi da 16 bit)
    
    msg1 db "Inserisci 3 numeri per Vet1:", 0Dh, 0Ah, "$"
    msg2 db "Inserisci 3 numeri per Vet2:", 0Dh, 0Ah, "$"
    msg_equal db "I due vettori sono uguali.$"
    msg_diff  db "I due vettori sono diversi.$"
    pkey db "Premi un tasto per uscire...$"
ends

stack segment
    dw 128 dup(0)
ends

code segment
start:
    mov ax, data
    mov ds, ax         ; Inizializza segmento dati
    mov es, ax         ; Inizializza segmento extra per l'output

    ; Stampa messaggio per Vet1
    mov dx, offset msg1
    mov ah, 09h
    int 21h
    
    ; Inserimento dati in Vet1
    lea si, Vet1
    call input_vector  

    ; Stampa messaggio per Vet2
    mov dx, offset msg2
    mov ah, 09h
    int 21h

    ; Inserimento dati in Vet2
    lea si, Vet2
    call input_vector

    ; Confronto dei vettori
    lea si, Vet1
    lea di, Vet2
    mov cx, 3          ; Numero di elementi nel vettore
    call compare_vectors

    ; Output del risultato
    jnz vectors_differ
    mov dx, offset msg_equal
    jmp print_result

vectors_differ:
    mov dx, offset msg_diff

print_result:
    mov ah, 09h
    int 21h

    ; Attendere la pressione di un tasto prima di uscire
    mov dx, offset pkey
    mov ah, 09h
    int 21h

    mov ah, 08h
    int 21h

    ; Uscita
    mov ah, 4Ch
    int 21h

;----------------------------------------------
; Subroutine per l'inserimento di un vettore
;----------------------------------------------
input_vector proc
    mov cx, 3        ; Ripeti per 3 elementi
next_input:
    call input_number
    stosw            ; Memorizza il valore letto in memoria
    loop next_input
    ret
input_vector endp

;----------------------------------------------
; Subroutine per confrontare due vettori
;----------------------------------------------
compare_vectors proc
    cld              ; Scansione in avanti
next_compare:
    lodsw            ; Carica un valore da Vet1 in AX
    scasw            ; Confronta con valore in Vet2
    jne not_equal
    loop next_compare
    ret
not_equal:
    stc              ; Imposta flag di carry se i vettori sono diversi
    ret
compare_vectors endp

;----------------------------------------------
; Subroutine per l'inserimento di un numero a 16 bit
;----------------------------------------------
input_number proc
    mov bx, 0        ; Inizializza BX per contenere il numero
next_digit:
    mov ah, 01h      ; Legge un carattere da tastiera
    int 21h
    cmp al, 0Dh      ; Controlla se preme "Invio"
    je end_input
    sub al, '0'      ; Converte da ASCII a numero
    mov ah, 0
    shl bx, 1        ; bx = bx * 2
    add bx, bx       ; bx = bx * 2 (otteniamo bx * 4)
    add bx, bx       ; bx = bx * 2 (otteniamo bx * 8)
    add bx, ax       ; bx = bx + numero inserito
    jmp next_digit
end_input:
    mov ax, bx       ; Ritorna il numero letto in AX
    ret
input_number endp

ends
end start
