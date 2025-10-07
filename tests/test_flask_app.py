import unittest
from flask_app import app, preprocessing_utility

class FlaskAppTests(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        cls.client = app.test_client()

    def test_home_page(self):
        response = self.client.get('/')
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'<title>Sentiment Analysis</title>', response.data)

    def test_predict_page(self):
        response = self.client.post('/predict', data=dict(text="I love this!"))
        self.assertEqual(response.status_code, 200)
        self.assertTrue(
            b'Positive Sentiment' in response.data or b'Negative Sentiment' in response.data,
            "Response should contain either 'Negative Sentiment' or 'Negative Sentiment'"
        )

if __name__ == '__main__':
    unittest.main()
