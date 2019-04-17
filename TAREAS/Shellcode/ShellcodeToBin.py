#!/usr/bin/env python
# -*- coding: utf-8 -*-

'''
Rodriguez Gallardo Pedro Alejandro
Plan de Becarios generacion 13
Curso: Analisis de Vulnerabilidades

Extrae los opcodes de un binario de ensamblador
'''

import re
import os
import sys
import getopt
import string
from subprocess import check_output

def getopts():
    try:
        usage_opt = ["file", "unicode", "numeric"]
        opts, args = getopt.getopt(sys.argv[1:], "f:un", usage_opt)

    except getopt.GetoptError as err:
        print(str(err))
        use()
        sys.exit(2)

    objfile = None
    shellcode = None
    formats = None

    for opt, arg in opts:
        if opt in ("-u", "--unicode"):
            formats = "unicode"
        elif opt in ("-n", "--numeric"):
            formats = "numeric"
        elif opt in ("-f", "--file"):
            objfile = arg
            if os.path.exists(objfile):
                shellcode = parse(objfile, formats)
            else:
                print("El archivo no existe")
                sys.exit(1)
        else:
            assert False, "Opcion no disponible"
    print(shellcode[:])

def use():
    print("Use: %s [options]" % __file__)
    print("")
    print("   -f, --file       Nombre del archivo")
    print("   -u, --unicode    Formato de salida Unicode \\u9090\\u9090")
    print("   -n, --numeric    Formato de salida Numerico 9090")
    print("")
    print("Ejemplo: %s -u -f <Archivo>"% __file__)
    print("         %s -n -f <Archivo>"% __file__)
    print("")


def parse(obj, formats):
    objdump = ['objdump', '-d', '-M', 'intel', obj]
    lines = check_output(objdump)
    lines = lines.split(b'Disassembly of section')[1]
    lines = lines.split(b'\n')[3:]

    shellcode = ""

    for line in lines:
        line = line.strip()
        # Colocamos en un arrreglo cada linea separada por \t
        tabs = line.split(b'\t')
        # Nos aseguramos que linea contenga mas de 2 elementos
        if (len(tabs) < 2):
            continue
        # Unicamente guardamos los elementos Bytes en formato Hexadecimal
        bytes = tabs[1].strip()

        # Damos formato al  shellcode
        bytes = bytes.split(b' ')
        shellcodeline = ""
        shellcodeline2 = ""
        for byte in bytes:
            if formats is None:
                shellcodeline += "\\x" + byte.decode("utf-8")
                shellcode += shellcodeline
            elif formats == 'unicode':
                shellcodeline += "\\u" + byte.decode("utf-8") + byte.decode("utf-8")
                shellcode += shellcodeline
            elif formats == 'numeric':
                shellcodeline += byte.decode("utf-8")
                shellcode += shellcodeline
    return shellcode

if __name__ == "__main__":
    if len(sys.argv) <= 1:
        use()
    else:
        getopts()
