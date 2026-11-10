export class HttpError extends Error {
  constructor(status, message, errors) {
    super(message);
    this.status = status;
    this.errors = errors;
  }
}

export function errorHandler(error, req, res, next) {
  if (res.headersSent) return next(error);
  if (error.code === 11000) {
    return res.status(409).json({ message: 'Email đã được sử dụng.' });
  }
  if (error.type === 'entity.too.large') {
    return res.status(413).json({ message: 'Dữ liệu quá lớn. Ảnh tối đa 2 MiB.' });
  }
  if (error instanceof SyntaxError && error.type === 'entity.parse.failed') {
    return res.status(400).json({ message: 'Nội dung JSON không hợp lệ.' });
  }
  if (error.name === 'ValidationError' || error.name === 'StrictModeError') {
    return res.status(400).json({ message: 'Dữ liệu sinh viên không hợp lệ.' });
  }
  if (error.status && error.status >= 400 && error.status < 500) {
    return res.status(error.status).json({
      message: error.message,
      ...(error.errors ? { errors: error.errors } : {}),
    });
  }
  // Never log a connection URI, password, request body or JWT.
  if (process.env.NODE_ENV !== 'test') console.error('Request failed:', error.name || 'Error');
  return res.status(500).json({ message: 'Máy chủ gặp lỗi. Vui lòng thử lại sau.' });
}
