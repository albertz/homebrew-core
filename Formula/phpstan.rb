class Phpstan < Formula
  desc "PHP Static Analysis Tool"
  homepage "https://github.com/phpstan/phpstan"
  url "https://github.com/phpstan/phpstan/releases/download/1.9.0/phpstan.phar"
  sha256 "8dab1c76bca621a22ebab5561f2f7390c72a3df6b716d8c6df48a2cd4ae97551"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "93357940dfd56bf5e94f885ffeb1c736aea641f1d9c67fc4fcabfcbea815d746"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "93357940dfd56bf5e94f885ffeb1c736aea641f1d9c67fc4fcabfcbea815d746"
    sha256 cellar: :any_skip_relocation, monterey:       "294d07827d7f2b7aa467e7d297c4e3bfc952c895b2c59f9c260ce1c714027a36"
    sha256 cellar: :any_skip_relocation, big_sur:        "294d07827d7f2b7aa467e7d297c4e3bfc952c895b2c59f9c260ce1c714027a36"
    sha256 cellar: :any_skip_relocation, catalina:       "294d07827d7f2b7aa467e7d297c4e3bfc952c895b2c59f9c260ce1c714027a36"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "93357940dfd56bf5e94f885ffeb1c736aea641f1d9c67fc4fcabfcbea815d746"
  end

  depends_on "php" => :test

  # Keg-relocation breaks the formula when it replaces `/usr/local` with a non-default prefix
  on_macos do
    on_intel do
      pour_bottle? only_if: :default_prefix
    end
  end

  def install
    bin.install "phpstan.phar" => "phpstan"
  end

  test do
    (testpath/"src/autoload.php").write <<~EOS
      <?php
      spl_autoload_register(
          function($class) {
              static $classes = null;
              if ($classes === null) {
                  $classes = array(
                      'email' => '/Email.php'
                  );
              }
              $cn = strtolower($class);
              if (isset($classes[$cn])) {
                  require __DIR__ . $classes[$cn];
              }
          },
          true,
          false
      );
    EOS

    (testpath/"src/Email.php").write <<~EOS
      <?php
        declare(strict_types=1);

        final class Email
        {
            private string $email;

            private function __construct(string $email)
            {
                $this->ensureIsValidEmail($email);

                $this->email = $email;
            }

            public static function fromString(string $email): self
            {
                return new self($email);
            }

            public function __toString(): string
            {
                return $this->email;
            }

            private function ensureIsValidEmail(string $email): void
            {
                if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
                    throw new InvalidArgumentException(
                        sprintf(
                            '"%s" is not a valid email address',
                            $email
                        )
                    );
                }
            }
        }
    EOS
    assert_match(/^\n \[OK\] No errors/,
      shell_output("#{bin}/phpstan analyse --level max --autoload-file src/autoload.php src/Email.php"))
  end
end
