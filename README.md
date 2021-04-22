# context-sudoku
A port of Peter Norvig's sudoku solver to Lua/ConTeXt

It provides four commands for typesetting sudokus and a command handler:

1. `\setupsudoku[#parameters]` and its alias `\setupsudokus[#parameters]`: as their names suggest, they serve to pass several options:

   As for the settings below, `even` and `odd` refer to sudoku blocks from left to right, from top to bottom:
  
   ```
   1 1 1 2 2 2 3 3 3
   1 1 1 2 2 2 3 3 3
   1 1 1 2 2 2 3 3 3
   4 4 4 5 5 5 6 6 6
   4 4 4 5 5 5 6 6 6
   4 4 4 5 5 5 6 6 6
   7 7 7 8 8 8 9 9 9
   7 7 7 8 8 8 9 9 9
   7 7 7 8 8 8 9 9 9
   ```
  
  The available parameters so far are the following:
  
  * `size`: for cell size. Default: `1.5em`
  * `align`: number alignment inside each cell. Default: `middle,lohi`
  * `evenbackground`: background for even blocks. Default: `color`
  * `oddbackground`: background for odd blocks. Default: `color`
  * `evenbackgroundcolor`: background color for even blocks. Default: `white`
  * `oddbackgroundcolor`: background color for odd blocks. Default: `gray`

2. `\sudoku[#parameters]{#content}`: typesets a sudoku. 
3. `\sudokufile[#parameters]{#content}`: typesets a sudoku from a file.
4. `\solvesudoku[#parameters]{#content}`: solves an incomplete sudoku. 
5. `\solvesudokufile[#parameters]{#content}`: solves an incomplete sudoku from a file.

   From 2 to 5, you are able to pass TABLE settings (the same as the ones used in `\setupTABLE`) via `#parameters`.

All the commands above handle with invalid cases or unsolvable sudokus.

Some examples are listed in [t-sudoku.mkvi](https://github.com/JairoAdelRio/context-sudoku/blob/main/t-sudoku.mkvi) and
can be visualized [here](https://github.com/JairoAdelRio/context-sudoku/blob/main/t-sudoku.pdf)
