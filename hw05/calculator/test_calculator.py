import unittest
from calculator import scitani, nasobeni

class TestKalkulacka(unittest.TestCase):
    def test_scitani(self):
        # Testování sčítání
        self.assertEqual(scitani(2, 3), 5)
        self.assertEqual(scitani(-2, 3), 1)
        self.assertEqual(scitani(0, 0), 0)
        self.assertEqual(scitani(100, 200), 300)

    def test_nasobeni(self):
        # Testování násobení
        self.assertEqual(nasobeni(2, 3), 6)
        self.assertEqual(nasobeni(-2, 3), -6)
        self.assertEqual(nasobeni(0, 5), 0)
        self.assertEqual(nasobeni(100, 0), 0)
        self.assertEqual(nasobeni(10, 10), 100)

if __name__ == '__main__':
    unittest.main()