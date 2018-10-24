//
//  Util.c
//  g2048
//
//  Created by LiZhengDa on 2018/10/24.
//  Copyright © 2018 Dan Lee. All rights reserved.
//

#include "Util.h"
#include <stdio.h>
#include <termios.h>
#include <unistd.h>

char xgetch() {
    char buf = 0;
    struct termios old = {0};
    if (tcgetattr(0, &old) < 0)
        perror("tcsetattr()");
    old.c_lflag &= ~ICANON;
    old.c_lflag &= ~ECHO;
    old.c_cc[VMIN] = 1;
    old.c_cc[VTIME] = 0;
    if (tcsetattr(0, TCSANOW, &old) < 0)
        perror("tcsetattr ICANON");
    if (read(0, &buf, 1) < 0)
        perror("read()");
    old.c_lflag |= ICANON;
    old.c_lflag |= ECHO;
    if (tcsetattr(0, TCSADRAIN, &old) < 0)
        perror("tcsetattr ~ICANON");
    return (buf);
}

void getInput(char *output) {
    *output = xgetch();
}
