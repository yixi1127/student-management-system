import jwt from 'jsonwebtoken'

export const authMiddleware = (req, res, next) => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '')
    
    if (!token) {
      return res.status(401).json({
        code: 401,
        message: '未提供认证令牌'
      })
    }
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET)
    req.user = decoded
    next()
  } catch (error) {
    return res.status(401).json({
      code: 401,
      message: '认证令牌无效或已过期'
    })
  }
}

export const checkRole = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        code: 403,
        message: '权限不足'
      })
    }
    next()
  }
}
