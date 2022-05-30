section .data
A_VEC_STANDART_CAP: dd 4 ; Rework!
    
section .text

extern  malloc
extern  memcpy
extern  memmove
extern  free

global _add
_add:

    mov rax, rcx
    add rax, rdx

ret

; *vec + 0 = vec->data
; *vec + 8 = vec->element_size
; *vec + 12 = vec->size
; *vec + 16 = vec->capacity

; typedef struct {
; 	void* data;
; 	int element_size;

; 	int size;
; 	int capacity;
; 	int test;
; } c_vector;

global _cvec_init ; rcx - *vec, rdx - dataSize
_cvec_init:

    push    rbp
    push    rbx
    mov     rbp, rsp
    
    sub     rsp, 32+8
    mov     rbx, rcx

    mov     QWORD[rbx+8],  rdx ; vec->dataSize
    mov     QWORD[rbx+16], 0   ; vec->size
    mov     QWORD[rbx+24], 4 ; vec->capacity

    mov     rax, QWORD[rbx+24] ; rax = vec->capacity

    imul    rax, rdx ; vec->element_size * vec->capacity
    mov     rcx, rax   ; rcx = vec->capacity

    call    malloc     ; rax =  malloc(vec->element_size * vec->capacity);

    mov     QWORD [rbx], rax  ; vec->data

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_copy  ; rcx - *vecF,  rdx - *vecS
_cvec_copy:
    push    rbp
    push    rbx
    mov     rbp, rsp
    sub     rsp, 32+24 ; alignment + (stak_spase % 16 + 8)

    mov     [rbp-8],    rcx 
    mov     [rbp-16],   rdx 

    mov     rax,    QWORD[rcx+24]  ; rax = vecF->capacity
    mov     rbx,    QWORD[rdx+16]  ; rbx = vecS->size

    cmp     rax,    rbx
    jae     Enough_S                ; if vecF->capacity >= vecS->size

    imul    rbx,   2
    mov     rdx,    rbx
    call _cvec_resize               ; vecF->capacity = vecS->size*2

Enough_S:
    
    mov     rcx,    QWORD[rbp-8]
    mov     rdx,    QWORD[rbp-16] 

    mov     rax,    QWORD[rdx+8]   ; vecS->dataSize
    mov     r8,     QWORD[rdx+16]  ; vecS->size
    mov     QWORD[rcx+16],    r8   ; vecF->size = vecS->size
    imul    r8,     rax

    mov     rcx,    QWORD[rcx]
    mov     rdx,    QWORD[rdx]
    call memcpy ;memcpy(vecF->daata (rcx), vecS->daata (rdx), vecS->element_size * vecS->size (r8));


    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_size
_cvec_size:

    mov     rax, QWORD[rcx+16] 
    
ret

global _cvec_capacity
_cvec_capacity:

    mov     rax, QWORD[rcx+24] 
    
ret

global _cvec_get  ; rcx - *vec, rdx - index
_cvec_get:

    mov [rsp-8], rbx ; сохраняем rbx
    sub rsp, 8

    mov rax, QWORD [rcx+8] ; rax = vec->datesize
    mov rbx, QWORD [rcx] ; rbx = adress of data
    
    imul rax, rdx ;  rax = vec->element_size * index
    add rax, rbx

    mov rbx, [rsp + 8] ; восстанавливаем значение rbx
    add rsp, 8

ret

global _cvec_set ; rcx - *vec, rdx - index, r8 - *Data
_cvec_set:

    push    rbp
    push    rbx
    mov     rbp, rsp
    sub     rsp, 32+24

    mov [rbp-8],    rcx 
    mov [rbp-16],   rdx 
    mov [rbp-32],   r8  

    call    _cvec_get ; rax = place

    mov     rcx,    rax            ; rcx = place
    mov     rdx,    QWORD[rbp-32]  ; rdx = *Data

    mov     rax,    QWORD[rbp-8]    ; rax = *vec
    mov     r8,     QWORD [rax+8]   ; r8 = vec->element_size

    call    memcpy    ;memcpy(place (rcx), data (rdx), vec->element_size (r8));

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_resize ; rcx - *vec, rdx - newCap
_cvec_resize:
     
    push    rbp
    push    rbx
    mov     rbp, rsp
    sub     rsp, 32+24

    mov [rbp-8],    rcx 
    mov [rbp-16],   rdx 

    mov     rbx,    QWORD[rcx+16]  ; rbx = vec->size
    cmp     rbx,    rdx                
    ja      Size_Fail               ; if vec->size > NewCap

    mov     QWORD[rcx+24], rdx     ; vec->capacity = newCap
    mov     rbx,     QWORD [rcx+8]  ; rax = vec->element_size
    
    imul    rbx,    rdx             ; rbx = vec->element_size * vec->capacity
    mov     rcx,    rbx             ; rcx = vec->element_size * vec->capacity

    call    malloc                  ; rax = new vec->data
    mov     [rbp-32],   rax 

    mov     rcx,     [rbp-8]        ; rcx = *vec
    mov     r8,    QWORD [rcx+8]   ; r8 = vec->element_size
    mov     rbx,    QWORD[rcx+16]  ; rbx = vec->size 
    imul    r8,    rbx              ; r8 = vec->element_size * vec->capacity
    
    mov     rdx,   QWORD [rcx]      ; rdx = vec->data
    mov     rcx,   [rbp-32]         ; rcx = new vec->data

    call    memcpy ;memcpy(new_vec->data (rcx), vec->data (rdx), vec->element_size * vec->size (r8));

    mov     rbx,     [rbp-8]        ; rbx = *vec
    mov     rcx,     QWORD[rbx]     ; rcx = vec->data
    call    free ;free(vec->data (rcx));

    mov     rax,    [rbp-32]        ; rax = new vec->data
    mov     QWORD [rbx], rax        ; vec->data = new vec->data

    mov     rax, 0

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

Size_Fail:
    mov     rax, -1

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_clear ; rcx - *vec
_cvec_clear:
    
    mov     QWORD[rcx+16], 0   ; vec->size
    mov     QWORD[rcx+24], 0   ; vec->capacity

    mov     rcx,     QWORD[rcx]     ; rcx = vec->data
    call    free ;free(vec->data (rcx));
ret

global _cvec_push_back ; rcx - *vec, rdx - *Data
_cvec_push_back:
    
    push    rbp
    push    rbx
    mov     rbp, rsp
    sub     rsp, 32+24 ; alignment + (stak_spase % 16 + 8)

    ;save:
    mov [rbp-8],    rcx 
    mov [rbp-16],   rdx

    mov     rax, QWORD[rcx+16]     ; rax = vec->size
    mov     rbx, QWORD[rcx+24]     ; rbx = vec->capacity
 
    cmp     rax, rbx                ;  mb need a >= check
    jne     N_isFull
    ;DoubleCap
    shl     rbx,    1
    mov     rdx,    rbx
    call _cvec_resize

N_isFull:

    mov     rcx,    QWORD[rbp-8]     
    
    mov     rbx,    QWORD[rcx+8]    ; rbx = vec->dataSize
    mov     r8,     QWORD[rcx+16]   ; r8d = vec->size
    imul    rbx,    r8              ; rbx = vec->size * vec->dataSize

    add     r8,     1               ; vec->size += 1
    mov     [rcx+16], r8
    
    mov     r8,     QWORD[rcx]      ; r8 = vec->data
    add     rbx,    r8              ; place = vec->data + (size * element_size);

    mov     r8,     QWORD[rcx+8]    ; rax = vec->dataSize
    mov     rcx,    rbx             ; rcx = place
    mov     rdx,    QWORD[rbp-16]
    call    memcpy ;memcpy(place(rcx), data (rdx), vec->element_size(r8));

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_pop_back ; rcx - *vec
_cvec_pop_back:

    mov [rsp-8], rbx ; сохраняем rbx
    sub rsp, 8

    mov     rbx, QWORD [rcx]    ; rbx = vec->data
    mov     rax, QWORD [rcx+8]  ; rax = vec->dataSize
    mov     rdx, QWORD[rcx+16]  ; rdx = vec->size

    sub     rdx, 1 ; size--
    imul rax, rdx ;  rax = vec[end]
    add rax, rbx

    mov     QWORD[rcx+16], rdx ; rax = vec->size--

    mov rbx, [rsp + 8] ; восстанавливаем значение rbx
    add rsp, 8
ret

global _cvec_del_el		; rcx = *vec, rdx = index
_cvec_del_el:
    push    rbp
    push    rbx
    mov     rbp, rsp
    sub     rsp, 32+24 ; alignment + (stak_spase % 16 + 8)
    ;save:
    mov     [rbp-8],    rcx 
    mov     [rbp-16],   rdx

    mov     rax,    QWORD[rcx+8]    ; rax = vec->dataSize
    mov     rbx,    QWORD[rcx]      ; rbx = vec->data
    add     rdx,    1               ; rdx = index + 1
    imul    rdx,    rax
    add     rdx,    rbx             ; rdx = source

    mov     rbx,    QWORD[rbp-16]   ; rbx = index
    mov     rax,    QWORD[rcx+8]    ; rax = vec->dataSize
    mov     r8,     QWORD[rcx+16]   ; r8 = vec->size
    add     rbx,    1               ; rdx = index + 1
    sub     r8,     rbx             ; r8 = (size-i)
    imul    r8,     rax             ; r8 = (size-(i + 1) * size_el)

    mov     rbx,    QWORD[rbp-16]   ; rbx = index
    mov     rax,    QWORD[rcx+8]    ; rax = vec->dataSize
    imul    rbx,    rax             ; rbx = index * size_el
    mov     rcx,    QWORD[rcx]      ; rcx = vec->data
    add     rcx,    rbx             ; rcx = destination

    call memmove ;(*destination (rcx), *source (rdx), (size-(i + 1) * size_el) (r8));

    mov     rcx,    QWORD[rbp-8]    ; rbx = index
    mov     rax,    QWORD[rcx+16]   ; rax = vec->size
    sub     rax,    1               ; rax = vec->size - 1
    mov     QWORD[rcx+16],    rax


    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret
