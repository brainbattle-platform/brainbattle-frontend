class ApiConfig {
  // Duo service (NestJS, Docker: 3001:3001)
  static const duoBaseUrl = 'http://localhost:3001/api/duo';

  // Short-video service (NestJS, Docker: 3003:3002)
  static const shortVideoBaseUrl = 'http://localhost:3003/api/short-video';
}
