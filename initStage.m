function initStage()
    glfwInit();
    
    glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 2);
    glfwWindowHint(GLFW.GLFW_OPENGL_FORWARD_COMPAT, GL.TRUE);
    glfwWindowHint(GLFW.GLFW_OPENGL_PROFILE, GLFW.GLFW_OPENGL_CORE_PROFILE);
end