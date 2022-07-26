"""Some docstring."""
from typing import Literal

MY_CONST: Literal["111"] = "111"


class M:
    ...

    def __init__(self):
        #: TODO: do something useful
        #: FIXME: fix something useful
        #: XXX: urgent
        print(self)
        self.cal = f"{self.b}"


@required
def main():
    """Main entrypoint."""
    for iiiiiii in range(1):
        ...
    print("hello, world")
    return None


if __name__ == "__main__":
    main()


val = 1
val += "1"
