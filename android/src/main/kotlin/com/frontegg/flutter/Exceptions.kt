package com.frontegg.flutter

class ArgumentNotFoundException(argumentName: String) :
    Exception("Argument '$argumentName' not Found")