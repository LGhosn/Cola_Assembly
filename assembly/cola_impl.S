#include "cola_asm.h"

.global cola_crear
.global cola_destruir
.global cola_encolar
.global cola_desencolar
.global cola_esta_vacia
.global cola_ver_primero

cola_crear:                /* Se recomienda usar calloc() */
  movq $SIZEOF_COLA, %rsi
  movq $1, %rdi
  call calloc
  cmpq $0, %rax
  je .FalloAlPedirMemoriaParaLaCola
  movq $0, OFFSET_HEAD(%rax)
  movq $0, OFFSET_TAIL(%rax)
  ret
.FalloAlPedirMemoriaParaLaCola:
  movq $0, %rax
  ret


cola_esta_vacia:           /* Se debe usar un conditional move (cmovXX/setXX) */
  cmpq $0, OFFSET_HEAD(%rdi)
  sete %al
  movzbl %al, %eax
  ret


cola_ver_primero:          /* Se debe usar un salto condicional */
  pushq %rbx
  movq %rdi, %rbx
  call cola_esta_vacia
  cmpq $1, %rax
  je .NoHayNadaParaVerEnLaCola
  movq OFFSET_HEAD(%rbx), %rax
  movq OFFSET_DATA(%rax), %rax
  popq %rbx
  ret
.NoHayNadaParaVerEnLaCola:
  movq $0, %rax
  popq %rbx
  ret


cola_encolar:              /* Se debe usar un conditional move */
  pushq %rbx
  pushq %r10
  pushq %r11
  pushq %r12
  movq %rdi, %rbx
  movq %rsi, %r12
  movq $SIZEOF_NODO, %rdi
  call malloc
  cmpq $0, %rax
  je .FalloAlPedirMemoriaParaElNodo
  movq %rax, %r11
  movq %r12, OFFSET_DATA(%rax)
  movq $0, OFFSET_NEXT(%rax)
  movq %rbx, %rdi
  call cola_esta_vacia
  cmpq $1, %rax
  movq OFFSET_TAIL(%rbx), %rax
  leaq OFFSET_NEXT(%rax), %r10
  cmove %rbx, %r10
  movq %r11, (%r10)
  movq %r11, OFFSET_TAIL(%rbx)
  movq $1, %rax
.ParteFinal:
  popq %r12
  popq %r11
  popq %r10
  popq %rbx
  ret
.FalloAlPedirMemoriaParaElNodo:
  movq $0, %rax
  jmp .ParteFinal


cola_desencolar:           /* Se recomienda usar dos saltos condicionales + un cmov */
  pushq %r12
  pushq %rbp
  pushq %rbx
  movq %rdi, %rbx
  call cola_esta_vacia
  cmpq $1, %rax
  je .NoHayNadaParaDesencolarEnLaCola
  movq OFFSET_HEAD(%rbx), %rbp
  movq OFFSET_DATA(%rbp), %r12
  movq OFFSET_NEXT(%rbp), %rax
  movq %rax, OFFSET_HEAD(%rbx)
  movq %rbx, %rdi
  call cola_esta_vacia
  cmpq $1, %rax
  je .LaColaTeniaUnElemento
.UltimaParte:
  movq %rbp, %rdi
  call free
.Terminar:
  movq %r12, %rax
  popq %rbx
  popq %rbp
  popq %r12
  ret
.LaColaTeniaUnElemento:
  movq $0, OFFSET_TAIL(%rbx)
  jmp .UltimaParte
.NoHayNadaParaDesencolarEnLaCola:
  movq $0, %r12
  jmp .Terminar
  ret


cola_destruir:             /* Sin restricciones */
  pushq %rbx
  movq %rdi, %rbx
.MientrasLaColaNoEsteVaciaHayQueDesencolar:
  movq %rbx, %rdi
  call cola_esta_vacia
  cmpq $1, %rax
  je .SeVacioLaCola
  movq	%rbx, %rdi
  call cola_desencolar
  jmp .MientrasLaColaNoEsteVaciaHayQueDesencolar
.SeVacioLaCola:
  movq	%rbx, %rdi
  call free
  popq %rbx
  ret
