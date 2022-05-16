section .data
A_VEC_STANDART_CAP: dd 4 ; Rework!
    
section .text

extern  malloc
extern  memcpy
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

    mov     DWORD [rbx+8],  edx ; vec->dataSize
    mov     DWORD [rbx+12], 0   ; vec->size
    mov     DWORD [rbx+16], 4 ; vec->capacity

    mov     eax, DWORD [rbx+16] ; eax = vec->capacity

    imul    eax, edx ; vec->element_size * vec->capacity
    mov     rcx, rax   ; rcx = vec->capacity

    call    malloc     ; rax =  malloc(vec->element_size * vec->capacity);

    mov     QWORD [rbx], rax  ; vec->data

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_size
_cvec_size:

    mov     eax, DWORD [rcx+12] 
    
ret

global _cvec_capacity
_cvec_capacity:

    mov     eax, DWORD [rcx+16] 
    
ret

global _cvec_get  ; rcx - *vec, rdx - index
_cvec_get:

    mov [rsp-8], rbx ; сохраняем rbx
    sub rsp, 8

    mov eax, DWORD [rcx+8] ; eax = vec->datesize
    mov rbx, QWORD [rcx] ; rbx = adress of data
    
    imul eax, edx ;  eax = vec->element_size * index
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
    mov     r8d,    DWORD [rax+8]   ; r8 = vec->element_size

    call    memcpy    ;memcpy(place (rcx), data (rdx), vec->element_size (r8));

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_resize ; rcx - *vec, rdx - newCap
    ; vec->capacity = newCap;

	; void* t = malloc(vec->element_size * vec->capacity);
	; memcpy(t, vec->data, vec->element_size * vec->size);

	; free(vec->data);
	; vec->data = t;
_cvec_resize:
     
    push    rbp
    push    rbx
    mov     rbp, rsp
    sub     rsp, 32+24

    mov [rbp-8],    rcx 
    mov [rbp-16],   rdx 

    mov     DWORD [rcx+16], edx     ; vec->capacity = newCap
    mov     ebx,     DWORD [rcx+8]  ; rax = vec->element_size
    
    imul    rbx,    rdx             ; rbx = vec->element_size * vec->capacity
    mov     rcx,    rbx             ; rcx = vec->element_size * vec->capacity

    call    malloc                  ; rax = new vec->data
    mov     [rbp-32],   rax 

    mov     rcx,     [rbp-8]        ; rcx = *vec
    mov     r8d,    DWORD [rcx+8]   ; r8 = vec->element_size
    mov     ebx,    DWORD [rcx+12]  ; rbx = vec->size
    
    imul    r8,    rbx              ; r8 = vec->element_size * vec->capacity
    mov     rdx,   QWORD [rcx]      ; rdx = vec->data
    mov     rcx,   [rbp-32]         ; rcx = new vec->data

    call    memcpy ;memcpy(new_vec->data (rcx), vec->data (rdx), vec->element_size * vec->size (r8));

    mov     rbx,     [rbp-8]        ; rbx = *vec
    mov     rcx,     QWORD[rbx]     ; rcx = vec->data
    call    free ;free(vec->data (rcx));

    mov     rax,    [rbp-32]        ; rax = new vec->data
    mov     QWORD [rbx], rax        ; vec->data = new vec->data

    mov     rsp, rbp
    pop     rbx
    pop     rbp
ret

global _cvec_pop_back ; rcx - *vec
_cvec_pop_back:

    mov [rsp-8], rbx ; сохраняем rbx
    sub rsp, 8

    mov     rbx, QWORD [rcx]    ; rbx = vec->data
    mov     eax, DWORD [rcx+8]  ; eax = vec->dataSize
    mov     edx, DWORD [rcx+12] ; edx = vec->size

    sub     edx, 1 ; size--
    imul eax, edx ;  eax = vec[end]
    add rax, rbx

    ;sub     edx, 1 ; size--
    mov     DWORD [rcx+12], edx ; eax = vec->size--

    mov rbx, [rsp + 8] ; восстанавливаем значение rbx
    add rsp, 8
ret

