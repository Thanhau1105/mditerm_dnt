import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware.js';
import { listUsers, getUser, createUser, updateUser, deleteUser } from '../controllers/userController.js';

const router = Router();
router.use(authenticate, requireAdmin);
router.route('/').get(listUsers).post(createUser);
router.route('/:id').get(getUser).put(updateUser).delete(deleteUser);
export default router;
