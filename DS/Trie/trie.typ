#set text(size: 10pt)
#set par(justify: true)

= Trie

A Trie (also called a prefix tree) is a tree-based data structure used to store and efficiently retrieve strings. Each node represents a character, and each path from the root represents a prefix of one or more stored strings. It supports efficient insertion, searching, and prefix queries in \(O(L)\), where \(L\) is the length of the string.

Integer Trie (Binary Trie):

An Integer Trie is a variation of the Trie designed to store integers in their binary representation instead of characters. Each number is represented by a path of bits (0 or 1), starting from the most significant bit. It is particularly useful for XOR-related problems, allowing efficient maximum or minimum XOR queries, insertion, and deletion in \(O(B)\), where \(B\) is the number of bits used to represent the integers.

#raw(read("code.cpp"), lang: "cpp", block: true)