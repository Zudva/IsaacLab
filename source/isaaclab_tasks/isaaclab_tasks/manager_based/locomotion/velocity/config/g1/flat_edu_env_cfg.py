# G1 EDU (23 DOF) flat terrain environment config.
from isaaclab.utils import configclass
from isaaclab.managers import SceneEntityCfg

from .flat_env_cfg import G1FlatEnvCfg
from isaaclab_assets import G1_EDU_CFG

@configclass
class G1EduFlatEnvCfg(G1FlatEnvCfg):
    def __post_init__(self):
        super().__post_init__()
        # Swap robot articulation to 23-DOF EDU variant
        self.scene.robot = G1_EDU_CFG.replace(prim_path="{ENV_REGEX_NS}/Robot")
        # Zero-out finger reward if present (keep object type consistent)
        if hasattr(self.rewards, "joint_deviation_fingers") and self.rewards.joint_deviation_fingers:
            self.rewards.joint_deviation_fingers.weight = 0.0
        # Adjust torque/accel L2 filters (remove finger joints patterns to avoid empty matches cost)
        if self.rewards.dof_torques_l2 and hasattr(self.rewards.dof_torques_l2, "params"):
            asset_cfg = self.rewards.dof_torques_l2.params.get("asset_cfg")
            if isinstance(asset_cfg, SceneEntityCfg):
                # keep only lower body + arms (regex already broad; OK)
                pass
        if self.rewards.dof_acc_l2 and hasattr(self.rewards.dof_acc_l2, "params"):
            asset_cfg = self.rewards.dof_acc_l2.params.get("asset_cfg")
            if isinstance(asset_cfg, SceneEntityCfg):
                pass

@configclass
class G1EduFlatEnvCfg_PLAY(G1EduFlatEnvCfg):
    def __post_init__(self):
        super().__post_init__()
        self.scene.num_envs = 50
        self.scene.env_spacing = 2.5
        self.observations.policy.enable_corruption = False
        # Disable disturbance events for play by setting zero probability if available
        if self.events.base_external_force_torque:
            if hasattr(self.events.base_external_force_torque, "params"):
                self.events.base_external_force_torque.params["probability"] = 0.0
        if self.events.push_robot:
            if hasattr(self.events.push_robot, "params"):
                self.events.push_robot.params["probability"] = 0.0
