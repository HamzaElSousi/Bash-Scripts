#!/usr/bin/bash

# Hamza El Sousi
# ID:040982818


# Check the number of arguments
if [ $# -lt 3 ]; then
  echo "Error: Too few arguments." >&2
  exit 1
fi

# Extract the operator and operands from the arguments
operator=$1
operand1=$2
operand2=$3



# Perform the calculation
case $operator in
  "+")
    result=$(($operand1 + $operand2))
    ;;
  "-")
    result=$(($operand1 - $operand2))
    ;;
  "x"|"*")
    result=$(($operand1 * $operand2))
    #result=$(($operand1 x $operand2))
    ;;
  "/")
    # Check if dividing by zero
if [ $operator = "/" ] && [ $operand2 -eq 0 ]; then
  echo "Error: Division by zero is not allowed." >&2
  exit 1
fi 
result=$(($operand1 / $operand2))
    ;;
esac

# Check if the operator is valid
if [[ ! $operator =~ ^(\+|-|/|x|\*)$ ]]; then
  echo "Error: Invalid operator. Please use +, -, x, or *." >&2
  exit 1
fi



# Output the result
echo $result

# Append the operation to calc.log
echo "$operand1 $operator $operand2 = $result" >> calc.log
