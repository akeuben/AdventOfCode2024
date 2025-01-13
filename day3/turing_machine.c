#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#define LEFT -1
#define RIGHT 1
#define STAY 0

#define ASCII_MIN ' '
#define ASCII_MAX '~'
#define ASCII_RANGE ASCII_MAX - ASCII_MIN
#define INSTRUCTION(S, Q, C) S[(Q)][(C) - ASCII_MIN]

char *tape;

typedef struct instruction {
    uint32_t state; // 1 character state maximum
    char new_character;
    int8_t direction;
    uint8_t valid;
} instruction_t;

// Yes, the total size of the instruction set will be ~25MB. People have
// plenty of RAM for this now, and is easier to implement as an array than a hash table.
// If I were using another language, I would opt for a hash table instead.
instruction_t **instruction_set;

void cleanup_instruction_set() {
    for(size_t i = 0; i < ASCII_RANGE; i++) {
        free(instruction_set[i]);
    }
    free(instruction_set);
}

void parse_instruction_set(const char *filename) {
    // Initialize the instruction set
    instruction_set = calloc(1024, sizeof(*instruction_set));
    for(size_t i = 0; i < 1024; i++) {
        instruction_set[i] = calloc(ASCII_RANGE, sizeof(instruction_set));
    }

    // Open instruction set file
    FILE *instruction_file = fopen(filename, "r");
    if(instruction_file == NULL) {
        fprintf(stderr, "Invalid machine file %s\n", filename);
        cleanup_instruction_set();
        exit(1);
    };

    int result = 0;
    uint32_t state;
    char character;
    uint32_t new_state;
    char new_character;
    int8_t direction;
    int line = 0;
    while(1) {
        result = fscanf(instruction_file, "q%d/%c->q%d/%c/%c\n", &state, &character, &new_state, &new_character, &direction);
        if(result == EOF) break;

        if(direction == 'L') {
            direction = -1;
        } else if(direction == 'R') {
            direction = 1;
        } else if(direction == 'S') {
            direction = 0;
        } else {
            printf("Invalid direction '%c'. Instruction is printed below:\n", direction);
            printf("Read instruction: q%d/%c->q%d/%c/%c\n", state, character, new_state, new_character, direction);
            printf("Error on line %d\n", line + 1);
            continue;
        }
        
        if(new_character == '`') new_character = '\0';

        const instruction_t instruction = {
            .state = new_state,
            .new_character = new_character,
            .direction = direction,
            .valid = 1,
        };

        INSTRUCTION(instruction_set, state, character) = instruction;
        line++;
    }

    fclose(instruction_file);
}

void cleanup_tape() {
    free(tape);
}

void parse_tape(const char *filename) {
    // Open instruction set file
    FILE *tape_file = fopen(filename, "r");
    if(tape_file == NULL) {
        fprintf(stderr, "Invalid tape file %s\n", filename);
        exit(1);
    };
    
    // Read length of file
    fseek(tape_file, 0L, SEEK_END);
    uint64_t length = ftell(tape_file);
    rewind(tape_file);

    char *raw_tape = calloc(length * 10 + 1, sizeof(char));
    tape = calloc(length * 10 + 1, sizeof(char));

    unsigned long result = fread(raw_tape, sizeof(char), length, tape_file);
    if(!result) {
        fprintf(stderr, "Failed to parse tape file\n");
    }
    raw_tape[length] = '\0';

    // Remove invalid characters
    size_t position = 0;
    for(size_t i = 0; i < length; i++) {
        if(raw_tape[i] < ASCII_MIN || raw_tape[i] > ASCII_MAX) continue;
        tape[position++] = raw_tape[i];
    }
    tape[position] = '\0';

    fclose(tape_file);
}

int main(int argc, char **argv) {
    parse_instruction_set(argv[1]);
    parse_tape(argv[2]);

    int state = 0;
    uint64_t head = 0;

    while(1) {
        char read = tape[head];
        if(read == '\0') {
            read = '`';
        }
        instruction_t instruction = INSTRUCTION(instruction_set, state, read);
        if(!instruction.valid) {
            printf("Halted on state %d with tape head reading %c\n\n", state, read);
            printf("Head: %ld.\nSurrounding:", head);
            for(int i = -10; i < 0; i++) {
                printf("%c", tape[head + i]);
            } 
            printf("[%c]", tape[head]);
            for(int i = 0; i < 10; i++) {
                printf("%c", tape[head + i]);
            } 
            printf("\n\n");
            break;
        }
        
        tape[head] = instruction.new_character;
        if(head != 0 || instruction.direction != -1) head += instruction.direction;
        state = instruction.state;
    }

    printf("%s\n", tape);

    cleanup_tape();
    cleanup_instruction_set();
    return 0;
}

