package ga;

import java.util.Comparator;

public class FitnessComparator implements Comparator<Chromosome>
{
    @Override
    public int compare(Chromosome firstChromosome, Chromosome secondChromosome)
    {
        if (firstChromosome.getFitness() < secondChromosome.getFitness())
        {
            return -1;
        }
        if (firstChromosome.getFitness() > secondChromosome.getFitness())
        {
            return 1;
        }
        return 0;
    }
}
