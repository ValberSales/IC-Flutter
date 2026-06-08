import { MenuItem } from "primeng/api";

export enum ETipoFeedback {
  VAZIO = 'VAZIO',
  ACERTO = 'ACERTO',
  ERRO = 'ERRO',
}

export class EFeedback {
  public static padrao: MenuItem[] = [
    { label: 'Muito bem!', value: ETipoFeedback.ACERTO },
    { label: 'Parabéns!', value: ETipoFeedback.ACERTO },
    { label: 'Acertou!', value: ETipoFeedback.ACERTO },
    { label: 'Na mosca!', value: ETipoFeedback.ACERTO },
    { label: 'Quase!', value: ETipoFeedback.ERRO },
    { label: 'Tente mais uma vez!', value: ETipoFeedback.ERRO },
    { label: 'Chegou perto!', value: ETipoFeedback.ERRO },
    { label: 'Você consegue!', value: ETipoFeedback.ERRO },
  ];
}
