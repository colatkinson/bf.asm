import unittest
import subprocess as sp
import os
import random
import tempfile


class BrainFuckOutput:
    def __init__(self, *, output: bytes, ret_code: int):
        self.output = output
        self.ret_code = ret_code


def run_bf_proc(exe: str, file: str, input: bytes = None) -> BrainFuckOutput:
    res = sp.run([*exe.split(" "), file], stdout=sp.PIPE, input=input)

    return BrainFuckOutput(output=res.stdout, ret_code=res.returncode)


class BaseTests:
    class BrainFuckTestBase(unittest.TestCase):
        exe = None

        def run_bf_proc(self, exe: str, file: str, input: bytes = None):
            raise NotImplementedError("run_bf_proc not implemented for subclass")

        def test_h(self):
            res = self.run_bf_proc(self.exe, "samples/h.bf")
            self.assertEqual(res.ret_code, 0)
            self.assertEqual(res.output, b"H\n")

        def test_hello_world(self):
            res = self.run_bf_proc(self.exe, "samples/hi_world.bf")
            self.assertEqual(res.ret_code, 0)
            self.assertEqual(res.output, b"Hello World!\n")

        def test_bitwidth(self):
            res = self.run_bf_proc(self.exe, "samples/bitwidth.bf")
            self.assertEqual(res.ret_code, 0)
            self.assertEqual(res.output, b"Hello World! 255\n")

        def test_input_basic(self):
            res = self.run_bf_proc(self.exe, "samples/one_char.bf", input=b"a")
            self.assertEqual(res.ret_code, 0)
            self.assertEqual(res.output, b"a")

        def test_rot13_basic(self):
            res = self.run_bf_proc(self.exe, "samples/rot13.b", input=b"hello, world!")
            self.assertEqual(res.ret_code, 0)
            self.assertEqual(res.output, b"uryyb, jbeyq!")

        def test_print_almost_every_char(self):
            res = self.run_bf_proc(self.exe, "samples/bytes.bf")
            self.assertEqual(res.ret_code, 0)

            expected = bytes(range(1, 256))
            self.assertEqual(res.output, expected)


class Test32(BaseTests.BrainFuckTestBase):
    exe = "build32/c-test"

    def run_bf_proc(self, exe, file, input=None):
        return run_bf_proc(exe, file, input)


class Test64(BaseTests.BrainFuckTestBase):
    """x86_64 tests"""

    exe = "build64/c-test"

    def run_bf_proc(self, exe, file, input=None):
        return run_bf_proc(exe, file, input)


def _dos_prep_path(path: str) -> str:
    """Convert a Unix-y path to a dosemu path."""
    return path.replace("/", "\\\\")


def _dos_prep_rel_path(path: str) -> str:
    """Convert a path relative to the root of the project to a dosemu path."""
    return _dos_prep_path(os.path.join("..", "..", path))


class TestDOS(BaseTests.BrainFuckTestBase):
    """Emulated DOS tests"""

    exe = "build16/dos/dos_test.com"

    def run_bf_proc(self, exe, file, input=None):
        tmp_dir = tempfile.gettempdir()

        # Generate a random file path, assuming that two parallel tests won't collide
        # Given that the odds are n_parallel_tests * 2^-64, I'm ok with this
        out_file_name = hex(random.getrandbits(64))[2:] + ".out"
        out_file_path = os.path.join(tmp_dir, out_file_name)

        quoted_input = ""
        if input is not None:
            input_suffix = '\\\\r\\\\^Z\\\\r"'
            quoted_input = f"-input \"{input.decode('ascii')}{input_suffix}"

        cmdln = (
            "dosemu",
            "-dumb",
            quoted_input,
            self.exe,
            '"' + _dos_prep_rel_path(file),
            ">",
            f"E:{_dos_prep_path(out_file_path)}",
            '"',
        )

        # We run in shell mode because there seems to be some funky escaping
        # going on with dosemu's arguments
        res = sp.run(" ".join(cmdln), stdout=sp.PIPE, stderr=sp.PIPE, shell=True)

        with open(out_file_path, "rb") as f:
            stdout = f.read()
        stdout = stdout.replace(b"   ", b"\t")

        if input is not None and stdout.endswith(b"\r\n"):
            stdout = stdout[:-2]

        return BrainFuckOutput(output=stdout, ret_code=res.returncode)


if __name__ == "__main__":
    unittest.main()
