from conans import ConanFile, tools
import os

repo_url = 'https://github.com/codegardenllc/tiny_gps_plus.git'
build_dir = os.getenv("BUILD_DIR", "build")
source_dir = os.getenv("PKG_SRC_DIR", None)


def lookup(name, default=None):
    v = default
    if os.path.exists(build_dir + "/" + name):
        v = tools.load(build_dir + "/" + name)
    return os.getenv("CONAN_" + name, v)


class ParticlePackage(ConanFile):
    name = "TinyGpsPlus"
    version = lookup("VERSION", "snapshot")
    settings = "os", "compiler", "build_type", "arch"
    url = "https://github.com/jw3/particle-cmakes"
    exports = build_dir + "/VERSION"
    generators = "cmake"
    requires = []

    def package(self):
        self.copy("*.cmake", src=f"{source_dir}/cmake")
        self.copy("*.c*", dst="src", src="firmware")
        self.copy("*.h*", dst="include", src="firmware")

    def source(self):
        self.run(f"git clone {repo_url} .")
